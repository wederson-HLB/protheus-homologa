#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : UATUWIP2
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 28/08/2014    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*---------------------*
User Function UATUWIP2()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {"Z29","Z55","Z27","Z49","Z46"}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                            "Atenção")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) , Final("Atualização efetuada.")),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/

Static Function UPDProc(lEnd)

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := { {04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof()
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf
		 dbSkip()
	  EndDo

	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada 
	  		    módulo. */

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next
			/*             
			//Atualizando uma tabela sem derrubar o sistema:
			__SetX31Mode(.F.) //opcional - para não permitir alterar o SX3
			
			X31UpdTable(cAlias) //Atualiza o cAlias baseado no SX3
			
			If __GetX31Error() //Verifica se ocorreu erro
				Alert(__GetX31Trace()) //Mostra os erros
			Endif
			*/

			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				 EndIf
				 X31UpdTable(aArqUpd[nx])
				 If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+;
					      aArqUpd[nx] +;
					      ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2) 

					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				 EndIf
				 
				 If !TCCanOpen(aArqUpd[nx])
				 	CHKFILE(aArqUpd[nx]) //Crio a tabela caso ela n exista
				 Endif
			 Next nX
			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex() )
				Exit 
			 EndIf 
		 Next nI 

		 If lOpen

			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center
		 EndIf
	  EndIf
   EndIf
End Sequence

Return(.T.)

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
Obs.        :
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

*----------------------------*
Static Function AtuSX3()
*----------------------------*
Local cTexto:=""

    //Cria consulta a Z57 - Natureza - com filtro
    ConsZ57(@cTexto)

    //Cria consulta a Z58 - Divisões - com filtro
    ConsZ58(@cTexto)
    
    //Cria as tabelas de proposta
    AtuProp(@cTexto)

    //Altera a capa da proposta
    AltZ55(@cTexto)

    //Altera a tabela de relacionamento de ação x legenda
    AltZ46(@cTexto)
    
    //Altera as tabelas de status
    AtuTabStatus(@cTexto)

    //Altera a tabela de status para incluir opções de revisar e encerrar a proposta em todas as etapas possíveis
	AtuRevCan(@cTexto)
	
	//Altera a tabela de parcelas de pagamentos para inclusão do campo código de overrun
	AltZ49(@cTexto)
	
	//Altera a tabela de alçadas
	AltZ42(@cTexto)

    //Altera a capa da proposta
    AltCN9(@cTexto)

	//Carga inicial na Z29 com base na Z54 	
	DeParaZ29(@cTexto)
	
Return(cTexto)


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
*--------------------------------*
Static Function ConsZ57(cTexto)
*--------------------------------*
DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Natureza de servico"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Natureza de servico"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Natureza de servico"
	endif
	SXB->XB_CONTEM:="Z57Z29"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Division"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Division"
	endif
	SXB->XB_CONTEM:="Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Desc Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Divisio"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Divisio"
	endif
	SXB->XB_CONTEM:="Z57_DESCDI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z57_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"01"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z57_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"07"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="07"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"08"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="08"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"09"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="09"
	SXB->XB_DESCRI:="Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Division"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Division"
	endif
	SXB->XB_CONTEM:="Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"10"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="10"
	SXB->XB_DESCRI:="Desc Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Divisio"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Divisio"
	endif
	SXB->XB_CONTEM:="Z57_DESCDI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"11"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="11"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z57_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"4"+"02"+"12"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="12"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z57_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z57->Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z57->Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57Z29"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57Z29"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="oGetDadosZ29:aCols[oGetDadosZ29:oBrowse:nAt][Ascan(aHeaderZ29,{|x| alltrim(x[2]) = 'Z29_CODDIV'})]==Z57->Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


cTexto += "Incluido/alterado no SXB consulta Z57Z29 para natureza de serviço "+NL   

Return cTexto


//Consulta com filtro para divisões
*-------------------------------*
Static Function ConsZ58(cTexto)
*-------------------------------*
Local lIncSXB	:= .F.

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Divisoes"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Divisiones"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Divisions"
	endif
	SXB->XB_CONTEM:="Z58"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+type"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Type"
	endif
	SXB->XB_CONTEM:="Z58_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"4"+"02"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"4"+"02"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z58->Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z58->Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z29"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z29"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	//SXB->XB_CONTEM:="M->Z29_TPCTR==Z58->Z58_TIPO "
	SXB->XB_CONTEM:="oGetDadosZ29:aCols[oGetDadosZ29:oBrowse:nAt][Ascan(aHeaderZ29,{|x| alltrim(x[2]) = 'Z29_TPCTR'})]==Z58->Z58_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta Z58Z29 para divisões "+NL 


Return cTexto


//proposta
*------------------------------*
Static Function AtuProp(cTexto)
*------------------------------*
Local aSX7:= {}
Local aSX3:= {}
Local aSX2:= {}
Local aSIX:= {}
Local aSXB:= {}
Local aSX6:= {}

Local aDelSX7:={}

************************************************************************************************************************************
//{SIX} - Índice
//AADD(aSix,{INDICE,ORDEM,CHAVE,DESCRICAO,DESCSPA,DESCENG,PROPRI,F3,NICKNAME,SHOWPESQ})

AADD(aSix,{'Z29','1','Z29_FILIAL+Z29_CODIGO','Codigo','Codigo','Codigo','U','','','S'})
AADD(aSix,{'Z29','2','Z29_FILIAL+Z29_NUMPRO+Z29_REVISA+Z29_CODIGO','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','U','','','S'})


AADD(aSix,{'Z27','1','Z27_FILIAL+Z27_NUMPRO+Z27_REVISA+Z27_CODIGO','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','U','','','S'})

************************************************************************************************************************************
//{SX2} - Tabela
//AADD(aSX2,{X2_CHAVE,X2_PATH,X2_ARQUIVO,X2_NOME,X2_NOMESPA,X2_NOMEENG,X2_ROTINA,X2_MODO,X2_MODOUN,X2_MODOEMP,X2_DELET,X2_TTS,X2_UNICO,X2_PYME,X2_MODULO,X2_DISPLAY,X2_SYSOBJ,X2_USROBJ})

if SM0->M0_CODIGO $ "99"
	AADD(aSX2,{'Z29','\SYSTEM\','Z29'+alltrim(SM0->M0_CODIGO)+'0','Desc Servico Nov Proposta','Desc Servico Nov Proposta','Desc Servico Nov Proposta','','C','C','C','','','','S','','','',''})
	AADD(aSX2,{'Z27','\SYSTEM\','Z27'+alltrim(SM0->M0_CODIGO)+'0','Overrun Nov Proposta','Overrun Nov Proposta','Overrun Nov Proposta','','C','C','C','','','','S','','','',''})
else
	AADD(aSX2,{'Z29','\SYSTEM\','Z29'+alltrim(SM0->M0_CODIGO)+'0','Desc Servico Nov Proposta','Desc Servico Nov Proposta','Desc Servico Nov Proposta','','E','E','E','','','','S','','','',''})
	AADD(aSX2,{'Z27','\SYSTEM\','Z27'+alltrim(SM0->M0_CODIGO)+'0','Overrun Nov Proposta','Overrun Nov Proposta','Overrun Nov Proposta','','E','E','E','','','','S','','','',''})
endif



************************************************************************************************************************************
//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_TITSPA,X3_TITENG,X3_DESCRIC,X3_DESCSPA,X3_DESCENG,X3_PICTURE,X3_VALID,X3_USADO,X3_RELACAO,X3_F3,X3_NIVEL,X3_RESERV,X3_CHECK,X3_TRIGGER,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_OBRIGAT,X3_VLDUSER,X3_CBOX,X3_CBOXSPA,X3_CBOXENG,X3_PICTVAR,X3_WHEN,X3_INIBRW,X3_GRPSXG,X3_FOLDER,X3_PYME,X3_CONDSQL,X3_CHKSQL,X3_IDXSRV,X3_ORTOGRA,X3_IDXFLD,X3_TELA,X3_AGRUP})

//item(serviço) da proposta
AADD(aSX3,{'Z29','01','Z29_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z29','02','Z29_ITEM'  ,'C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z29','03','Z29_CODIGO','C','15','','Codigo','Codigo','Code','Codigo Servico','Codigo Servico','Service Code','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','04','Z29_NUMPRO','C','12','','Proposta','Proposta','Proposta','Proposta','Proposta','Proposta','','','€€€€€€€€€€€€€€€','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','05','Z29_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€€','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','06','Z29_TPCTR' ,'C','1','','Tipo','Tipo','Tipo','Tipo Contrato','Tipo Contrato','Tipo Contrato','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','€','','1=AUDITING;2=TAX;3=ADVISORY','','','','IIF(oGetDadosZ29:oBrowse:nAt==1,.F.,.T.)','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','07','Z29_CODDIV','C','6','','Divisao','Divisao','Divisao','Codigo Divisao','Codigo Divisao','Division code','','','€€€€€€€€€€€€€€ ','','Z58Z29','','þA','','S','U','S','A','R','€','ExistCpo("Z58",M->Z29_CODDIV,1) .AND. U_GTSXB004("Z29_CODDIV")','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','08','Z29_DESCDI','C','100','','Desc divisao','Desc divisio','Desc divisio','Descricao da divisão','Descripcion da division','Division description','','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"",POSICIONE("Z58",1,xFilial("SED")+Z29->Z29_CODDIV,"Z58_DESCRI"))','','','þA','','S','U','S','V','V','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','09','Z29_CODNAT','C','6','','Natureza','Natureza','Natureza','Codigo Natureza','Codigo Natureza','Division Natureza','','','€€€€€€€€€€€€€€ ','','Z57Z29','','þA','','S','U','S','A','R','€','ExistCpo("Z57",M->Z29_CODNAT,1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','10','Z29_DESCNA','C','100','','Desc Naturez','Desc Naturez','Desc Naturez','Descricao da Natureza','Descripcion da Natureza','Natureza description','','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"",POSICIONE("Z57",1,xFilial("Z57")+Z29->Z29_CODNAT,"Z57_DESCRI"))','','','þA','','S','U','S','V','V','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','11','Z29_HORAPR','N','9','1','Horas Previs','Horas Previs','Hours Previs','Horas Previstas','Horas Previstas','Hours Previstas','@E 9999999.9','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','12','Z29_CUSTOT','N','14','2','Vl. Orcado','Vl. Orcado','Vl. Orcado','Valor Orcado','Valor Orcado','Valor Orcado','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','13','Z29_PRECOL','N','14','2','Preco Liq','Preco Liq','Preco Liq','Preço Liquido','Preço Liquido','Preço Liquido','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','14','Z29_PRELSU','N','14','2','Pr Liq+Sur','Pr Liq+Sur','Pr Liq+Sur','Preço Liq.+Sur','Preço Liq.+Sur','Preço Liq.+Sur','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','15','Z29_TAXAME','N','8','2','Tx.Media Liq','Tx.Media Liq','Tx.Media Liq','Taxa Media Liquida','Taxa Media Liquida','Taxa Media Liquida','@E 9,999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','16','Z29_TXMESU','N','8','2','Tx.Media+Sur','Tx.Media+Sur','Tx.Media+Sur','Tx.Media Liq.+Sur','Tx.Media Liq.+Sur','Tx.Media Liq.+Sur','@E 9,999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','17','Z29_RECUPE','N','6','2','% Recuperaca','% Recuperaca','% Recuperaca','% Recuperacao','% Recuperacao','% Recuperacao','@E 999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','18','Z29_SOCIO','C',cvaltochar(TamSX3("RA_CIC")[1]),'','Socio','Socio','Partner','Socio','Socio','Partner','@!','','€€€€€€€€€€€€€€ ','','Z42SOC','','þA','','S','U','N','A','R','€','U_GTSXB005("1",.T.)','','','','','IIF(oGetDadosZ29:oBrowse:nAt==1,.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','19','Z29_NOMESO','C','100','','Nome Socio','Nome Socio','Partner Name','Nome Socio','Nome Socio','Partner Name','','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"",U_GTSXB002(Z29->Z29_SOCIO))','','','þA','','','U','S','V','V','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','20','Z29_GERENT','C',cvaltochar(TamSX3("RA_CIC")[1]),'','Gerente','Gerente','Manager','Gerente','Gerente','Manager','@!','','€€€€€€€€€€€€€€ ','','Z42GER','','þA','','S','U','N','A','R','','U_GTSXB005("2",.T.)','','','','','IIF(oGetDadosZ29:oBrowse:nAt==1,.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','21','Z29_NOMEGE','C','100','','Nome Gerente','Nome Gerente','Manager Name','Nome Gerente','Nome Gerente','Manager Name','','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"",U_GTSXB002(Z29->Z29_GERENT))','','','þA','','','U','S','V','V','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z29','22','Z29_DTAINI','D','8','','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','','','€€€€€€€€€€€€€€ ','CTOD("//")','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','23','Z29_DTAFIM','D','8','','Data Final','Data Final','Data Final','Data Final','Data Final','Data Final','','','€€€€€€€€€€€€€€ ','CTOD("//")','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','24','Z29_FILORI','C','2','','Fil Origem','Fil Origem','Fil Origem','Filial Origem','Filial Origem','Filial Origem','','','€€€€€€€€€€€€€€€','cFilAnt','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z29','25','Z29_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z29','26','Z29_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})


AADD(aSX3,{'Z27','01','Z27_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z27','02','Z27_NUMPRO','C','12','','Proposta','Proposta','Proposta','Proposta','Proposta','Proposta','','','€€€€€€€€€€€€€€€','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','03','Z27_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€€','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','04','Z27_CODIGO','C','6','','Codigo','Codigo','Code','Codigo Servico','Codigo Servico','Service Code','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','V','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','05','Z27_DTAINC','D','8','','Data ','Data','Date','Data Inclusao','Data Inclusao','Inclusion Date','','','€€€€€€€€€€€€€€ ','CTOD("//")','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','06','Z27_HORAPR','N','9','1','Horas Previs','Horas Previs','Hours Previs','Horas Previstas','Horas Previstas','Hours Previstas','@E 9999999.9','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','07','Z27_MOEDA','C','2','','Moeda','Moneda','Currency','Moeda','Moneda','Currency','@!','','€€€€€€€€€€€€€€ ','"01"','CTO','','›€','','S','U','S','A','R','','ExistCpo("CTO", M->Z27_MOEDA, 1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','08','Z27_VLRLIQ','N','14','2','Vlr liquid','Vlr liquid','Vlr liquid','Valor liquido','Valor liquido','Valor liquido','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z27','09','Z27_TAXAME','N','8','2','Tx.Media Liq','Tx.Media Liq','Tx.Media Liq','Taxa Media Liquida','Taxa Media Liquida','Taxa Media Liquida','@E 9,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z27','10','Z27_IMPOST','N','6','2' ,'% Imposto','% Imposto','% Imposto','% Imposto','% Imposto','% Imposto','@E 999.99','','€€€€€€€€€€€€€€ ','val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z27','11','Z27_VLRTOT','N','14','2','Vlr Bruto','Vlr Bruto','Vlr Bruto','Vlr Bruto','Valor bruto','Valor bruto','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z27','12','Z27_FILORI','C','2','','Fil Origem','Fil Origem','Fil Origem','Filial Origem','Filial Origem','Filial Origem','','','€€€€€€€€€€€€€€€','cFilAnt','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z27','13','Z27_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z27','14','Z27_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})

//Inclusão de campos na aba principal da proposta

****************************************************************************************************************************************** 
//{SX7} - Gatilhos
//AADD(aSX7,{X7_CAMPO,X7_SEQUENC,X7_REGRA,X7_CDOMIN,X7_TIPO,X7_SEEK,X7_ALIAS,X7_ORDEM,X7_CHAVE,X7_CONDIC,X7_PROPRI})

AADD(aSX7,{'Z29_CODDIV','001','POSICIONE("Z58",1,xFilial("SED")+M->Z29_CODDIV,"Z58_DESCRI")','Z29_DESCDI','P','N','','','','','U',''})
AADD(aSX7,{'Z29_CODDIV','002','SPACE(TamSX3("Z29_CODNAT")[1])','Z29_CODNAT','P','N','','','','','U',''})
AADD(aSX7,{'Z29_CODDIV','003','SPACE(TamSX3("Z29_DESCNA")[1])','Z29_DESCNA','P','N','','','','','U',''})
AADD(aSX7,{'Z29_CODNAT','001','POSICIONE("Z57",1,xFilial("Z57")+M->Z29_CODNAT,"Z57_DESCRI")','Z29_DESCNA','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','001','STRZERO(val(SUBSTR(M->Z54_HORAPR,1,5)),5)+":"+STRZERO(val(SUBSTR(M->Z54_HORAPR,7,2)),2)','Z54_HORAPR','P','N','','','','','U',''})

//AADD(aSX7,{'Z54_CUSTOT','001','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aSX7,{'Z29_HORAPR','001','M->Z29_PRECOL/M->Z29_HORAPR','Z29_TAXAME','P','N','','','','','U',''})
AADD(aSX7,{'Z29_HORAPR','002','M->Z29_PRELSU/M->Z29_HORAPR','Z29_TXMESU','P','N','','','','','U',''})

//AADD(aSX7,{'Z54_TAXAME','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_TAXAME','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aSX7,{'Z29_PRECOL','001','M->Z29_PRECOL + (M->Z29_PRECOL * (M->Z55_SURCHA / 100))','Z29_PRELSU','P','N','','','','','U',''})
AADD(aSX7,{'Z29_PRECOL','002','(M->Z29_PRELSU * 100)/M->Z29_CUSTOT','Z29_RECUPE','P','N','','','','','U',''})
AADD(aSX7,{'Z29_PRECOL','003','M->Z29_PRECOL/M->Z29_HORAPR','Z29_TAXAME','P','N','','','','','U',''})
AADD(aSX7,{'Z29_PRECOL','004','M->Z29_PRELSU/M->Z29_HORAPR','Z29_TXMESU','P','N','','','','','U',''})
//AADD(aSX7,{'Z29_PRECOL','005','U_Z54CUSTO()','Z55_VLRLIQ','P','N','','','','','U',''})

AADD(aSX7,{'Z29_CUSTOT','001','(M->Z29_PRELSU * 100)/M->Z29_CUSTOT','Z29_RECUPE','P','N','','','','','U',''})


AADD(aSX7,{'Z29_TPCTR ','001','U_GTSX7003()','Z29_TPCTR','P','N','','','','','U',''})


AADD(aSX7,{'Z29_SOCIO ','001','U_GTSXB002(M->Z29_SOCIO)','Z29_NOMESO','P','N','','','','','U',''})

AADD(aSX7,{'Z29_GERENT','001','U_GTSXB002(M->Z29_GERENT)','Z29_NOMEGE','P','N','','','','','U',''})

//AADD(aSX7,{'Z54_RECORR','001','Space(3)','Z54_RECQTD','P','N','','','','M->Z54_RECORR == "N"','U',''})
//AADD(aSX7,{'Z54_RECORR','002','Space(4)','Z54_ANOINI','P','N','','','','M->Z54_RECORR == "N"','U',''})


AADD(aSX7,{'Z55_CODCON','001','POSICIONE("Z28",1,xFilial("Z28")+M->Z55_CODCON,"Z28_NOME")','Z55_NOMCON','P','N','','','','','U',''})

AADD(aSX7,{'Z55_SOCIO','002','U_GTSX7005("SOCIO")','Z55_SOCIO','P','N','','','','','U',''})
AADD(aSX7,{'Z55_GERENT','002','U_GTSX7005("GERENTE")','Z55_GERENT','P','N','','','','','U',''})

//INCLUIDO PARA DELETAR

***************************************************************************************************************************************** 
//{SXB} - Consulta Padrão
//AADD(aSXB,{XB_ALIAS,XB_TIPO,XB_SEQ,XB_COLUNA,XB_DESCRI,XB_DESCSPA,XB_DESCENG,XB_CONTEM,XB_WCONTEM})


AADD(aSXB,{'Z42SOC','1','01','DB','Socio responsavel','Socio responsavel','Socio responsavel','Z42',''})
AADD(aSXB,{'Z42SOC','2','01','02','Cpf','Cpf','Cpf','',''})
AADD(aSXB,{'Z42SOC','2','02','03','Nome Funcio','Nome Funcio','Nome Funcio','',''})
AADD(aSXB,{'Z42SOC','4','01','01','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42SOC','4','01','02','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42SOC','4','02','01','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42SOC','4','02','02','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42SOC','5','01','','','','','Z42->Z42_CPF',''})
AADD(aSXB,{'Z42SOC','6','01','','','','','Z42->Z42_TIPOFU=="1"',''})

AADD(aSXB,{'Z42GER','1','01','DB','Gerente responsavel','Gerente responsavel','Gerente responsavel','Z42',''})
AADD(aSXB,{'Z42GER','2','01','02','Cpf','Cpf','Cpf','',''})
AADD(aSXB,{'Z42GER','2','02','03','Nome Funcio','Nome Funcio','Nome Funcio','',''})
AADD(aSXB,{'Z42GER','4','01','01','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42GER','4','01','02','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42GER','4','02','01','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42GER','4','02','02','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42GER','5','01','','','','','Z42->Z42_CPF',''})
AADD(aSXB,{'Z42GER','6','01','','','','','Z42->Z42_TIPOFU=="2"',''})

****************************************************************************************************************************************** 
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME,X6_VALID,X6_INIT,X6_DEFPOR,X6_DEFSPA,X6_DEFENG})


if SM0->M0_CODIGO $ "99"
	AADD(aSX6,{'','MV_P_00017','C','E-mails que recebem aviso sobre inclusão de ','','','proposta (QRM e Pool)','','','','','','matheus.massarotto@br.gt.com','matheus.massarotto@br.gt.com','matheus.massarotto@br.gt.com','U','','','','','',''})
	AADD(aSX6,{'','MV_P_00018','C','E-mails que recebem aviso sobre inclusão de ','','','revisão no pool'	   ,'','','','','','matheus.massarotto@br.gt.com','matheus.massarotto@br.gt.com','matheus.massarotto@br.gt.com','U','','','','','',''})
else
	AADD(aSX6,{'','MV_P_00017','C','E-mails que recebem aviso sobre inclusão de ','','','proposta (QRM e Pool)','','','','','','comercial@br.gt.com;independencia@br.gt.com','comercial@br.gt.com;independencia@br.gt.com','comercial@br.gt.com;independencia@br.gt.com','U','','','','','',''})
	AADD(aSX6,{'','MV_P_00018','C','E-mails que recebem aviso sobre inclusão de ','','','revisão no pool'	   ,'','','','','','comercial@br.gt.com','comercial@br.gt.com','comercial@br.gt.com','U','','','','','',''})
endif


****************************************************************************************************************************************** 
//<Chamada das funções para a deleção dos dicionários -- **NÃO MEXER** >
DeletSx7(aDelSX7,cTexto)
//<FIM - Chamada das funções para a deleção dos dicionários >

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

CriaSx2(aSX2,@cTexto)

CriaSix(aSIX,@cTexto) 

CriaSx7(aSX7,@cTexto)

CriaSxb(aSXB,@cTexto)

CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------*
Static Function AltZ55(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.
Local lContinua	:= .F.
Local lFisrt	:= .T.

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z55"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z55'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z55_PROJNO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z55"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z55_PROJNO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nome Projeto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nome Projeto"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Project Name"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Nome Projeto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Nome Projeto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Project Name"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z55_PROJNO no SX3 da tabela Z55 "+NL


//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z55"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z55'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z55_ANOAUD"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z55"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z55_ANOAUD"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=4
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Data Base"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Data Base"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Base Date"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Data Base"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Data Base"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Base Date"
	endif
	SX3->X3_PICTURE:="9999"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z55_ANOAUD no SX3 da tabela Z55 "+NL

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z55"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z55'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z55_CODCON"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z55"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z55_CODCON"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Concorrente"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Concorrente"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Competitor"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo Concorrente"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo Concorrente"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Competitor Code"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:="IIF(INCLUI,'',POSICIONE('Z28',1,xFilial('Z28')+Z55->Z55_CODCON,'Z28_NOME'))"
	SX3->X3_F3:="Z28"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:='ExistCpo("Z28",M->Z55_CODCON,1)'
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_WHEN:="IIF(M->Z55_MOTREC<>'2',.F.,.T.)"
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1" 

SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z55_CODCON no SX3 da tabela Z55 "+NL
            

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z55"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z55'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z55_NOMCON"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z55"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z55_NOMCON"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=60
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nome Concorre"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nome Concorre"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Competit Name"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Nome Concorrente"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Nome Concorrente"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Competitor Name"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
	SX3->X3_CONTEXT:="V"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z55_NOMCON no SX3 da tabela Z55 "+NL

lContinua	:= .F.
lFisrt		:= .T.

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("Z55_OBSREC"))
	cOrdemIni	:= SX3->X3_ORDEM	
	cOrdem		:= SX3->X3_ORDEM	

	//if SX3->(DbSeek("Z55_CODCON")) .AND. SX3->(DbSeek("Z55_NOMCON"))

		SX3->(DbSetOrder(1))
		SX3->(DbGotop())
		if DbSeek("Z55"+SOMA1(cOrdem))
        	if alltrim(SX3->X3_CAMPO)<>"Z55_CODCON"
        		lContinua:=.T.
        	endif
		endif

		//Se a ordem ainda não foi arrumada
		if lContinua

			SX3->(DbSetOrder(1))
			SX3->(DbGotop())
			if DbSeek("Z55"+cOrdem)

		    	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == 'Z55'

		    	    RecLock("SX3",.F.)
						SX3->X3_ORDEM:=cOrdem	
					MsUnlock()	
		    		
		    		if lFisrt
		    			
		    			cOrdem:=SOMA1(cOrdem)
		    			cOrdem:=SOMA1(cOrdem)
		    			
			    		lFisrt:=.F.
		
		    		else
			    		cOrdem:=SOMA1(cOrdem)
		    		endif
		    		
		    		SX3->(DbSkip())
		    	Enddo
	
		    endif
		    
		
		
	//endif
			SX3->(DbSetOrder(2))
			SX3->(DbGotop())	

			if SX3->(DbSeek("Z55_CODCON"))		
			
				cOrdemIni:=SOMA1(cOrdemIni)
			   
				RecLock("SX3",.F.)
					SX3->X3_ORDEM:=cOrdemIni	
				MsUnlock()
			endif
		
			cTexto += "Alterado ordem dos campos Z55_CODCON no SX3 da tabela Z55 "+NL
	
		endif
	
endif

lContinua	:= .F.
lFisrt		:= .T.

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("Z55_CODCON"))
	cOrdemIni	:= SX3->X3_ORDEM	
	cOrdem		:= SX3->X3_ORDEM	

	//if SX3->(DbSeek("Z55_CODCON")) .AND. SX3->(DbSeek("Z55_NOMCON"))

		SX3->(DbSetOrder(1))
		SX3->(DbGotop())
		if DbSeek("Z55"+SOMA1(cOrdem))
        	if alltrim(SX3->X3_CAMPO)<>"Z55_NOMCON"
        		lContinua:=.T.
        	endif
		endif

		//Se a ordem ainda não foi arrumada
		if lContinua

			SX3->(DbSetOrder(1))
			SX3->(DbGotop())
			if DbSeek("Z55"+cOrdem)

		    	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == 'Z55'

		    	    RecLock("SX3",.F.)
						SX3->X3_ORDEM:=cOrdem	
					MsUnlock()	
		    		
		    		if lFisrt
		    			
		    			cOrdem:=SOMA1(cOrdem)
		    			cOrdem:=SOMA1(cOrdem)
		    			
			    		lFisrt:=.F.
		
		    		else
			    		cOrdem:=SOMA1(cOrdem)
		    		endif
		    		
		    		SX3->(DbSkip())
		    	Enddo
	
		    endif
		    
		
		
	//endif
			SX3->(DbSetOrder(2))
			SX3->(DbGotop())	

			if SX3->(DbSeek("Z55_NOMCON"))
				
				cOrdemIni:=SOMA1(cOrdemIni)
			   
				RecLock("SX3",.F.)
					SX3->X3_ORDEM:=cOrdemIni
				MsUnlock()
			endif

			cTexto += "Alterado ordem dos campos Z55_NOMCON no SX3 da tabela Z55 "+NL
	
		endif
	
endif

//Atualiza os campos que aparecem na visualização do browse
SX3->(DbSetOrder(1))
SX3->(DbGotop())
if DbSeek("Z55")

	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == 'Z55'
	    
		if UPPER(alltrim(SX3->X3_CAMPO)) $ "Z55_FILIAL/Z55_DESCST/Z55_TPCTR/Z55_NUM/Z55_REVISA/Z55_PNOME/Z55_NOME/Z55_NOMESO/Z55_NOMEGE/Z55_PROJNO/Z55_ANOAUD"
			RecLock("SX3",.F.)
				SX3->X3_BROWSE:="S"
			MsUnlock()	
		else
			RecLock("SX3",.F.)
				SX3->X3_BROWSE:="N"
			MsUnlock()		
		endif
		
		SX3->(DbSkip())
	Enddo
endif	


cTexto += "Alterado visualização no browse dos campos no SX3 da tabela Z55 "+NL


SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("Z55_SOCIO"))
	RecLock("SX3",.F.)
		SX3->X3_VLDUSER	:= "U_GTSXB005('1')"
	MsUnlock()

	cTexto += "Alterado validação de usuário do campo Z55_SOCIO no SX3 da tabela Z55 "+NL
endif
 

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("Z55_GERENT"))
	RecLock("SX3",.F.)
		SX3->X3_VLDUSER	:= "U_GTSXB005('2')"
	    SX3->X3_F3		:= "Z42GER"
	MsUnlock()

	cTexto += "Alterado validação de usuário do campo Z55_GERENT no SX3 da tabela Z55 "+NL
endif

Return

*-----------------------------*
Static Function AltCN9(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.
Local lContinua	:= .F.
Local lFisrt	:= .T.
Local cOrdem	:= ""

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CN9_P_GER"))
	RecLock("SX3",.F.)
		SX3->X3_USADO	:= "€€€€€€€€€€€€€€€"
		SX3->X3_OBRIGAT	:= ""
	SX3->(MsUnlock())
endif

cTexto += "Incluido/alterados o campo CN9_P_INDI no SX3 da tabela CN9 "+NL


//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "CN9"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'CN9'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem


SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("CN9_P_NSOC"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="CN9"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="CN9_P_NSOC"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nome Socio"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nome Socio"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Partner Name"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Nome Socio"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Nome Socio"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Partner Name"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
	SX3->X3_CONTEXT:="V"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo CN9_P_NSOC no SX3 da tabela CN9 "+NL

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CN9_P_INDI"))
	RecLock("SX3",.F.)
		SX3->X3_OBRIGAT:=""
	SX3->(MsUnlock())
endif

cTexto += "Incluido/alterados o campo CN9_P_INDI no SX3 da tabela CN9 "+NL


SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CN9_P_NSOC"))
	
	if SX3->X3_ORDEM <> "05"
        
		SX3->(DbSeek("CN9_P_GER"))
    	cOrdem:= SX3->X3_ORDEM
    	
    	While SX3->(!EOF()) .AND. alltrim(SX3->X3_ARQUIVO) == "CN9"

			cOrdem:=SOMA1(cOrdem)
            
            RecLock("SX3",.F.)
				SX3->X3_ORDEM:=cOrdem
            SX3->(MsUnlock())
			
			SX3->(DbSkip())			
    	Enddo

    	if SX3->(DbSeek("CN9_P_NSOC"))
	    	RecLock("SX3",.F.)
	    		SX3->X3_ORDEM:="05"
	    	SX3->(MsUnLock())
        endif
    endif

	cTexto += "Incluido/alterados a ordem do campo CN9_P_NSOC no SX3 da tabela CN9 "+NL
endif

Return

//Altera a tabela de relacionamento de ações x legenda da proposta
*-----------------------------*
Static Function AltZ46(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.
Local lContinua	:= .F.
Local lFisrt	:= .T.

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z46"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z46'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z46_LEGSUB"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z46"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z46_LEGSUB"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Leg Substitu"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Leg Substitu"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Leg Substitu"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Legenda Substituta"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Legenda Substituta"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Legend Substitute"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z46_LEGSUB no SX3 da tabela Z46 "+NL


//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z46"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z46'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z46_DESSUB"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z46"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z46_DESSUB"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Des Substitu"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Des Substitu"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Des Substitu"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao Substituta"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descricao Substituta"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description Substitute"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z46_DESSUB no SX3 da tabela Z46 "+NL

Return


*-----------------------------*
Static Function AltZ49(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.
Local lContinua	:= .F.
Local lFisrt	:= .T.

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "Z49"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'Z49'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("Z49_CODOVE"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z49"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="Z49_CODOVE"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Cod Overrun"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Cod Overrun"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Cod Overrun"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Cod Overrun"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Cod Overrun"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Cod Overrun"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þÀ"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo Z49_CODOVE no SX3 da tabela Z49 "+NL


//{SIX} - Índice
DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z492"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z49"
	SIX->ORDEM:="2"
	SIX->CHAVE:="Z49_FILIAL+Z49_PROPOS+Z49_REVISA+Z49_TIPO+Z49_CODOVE"
	SIX->DESCRICAO:="Proposta+Revisao+Tipo+Cod Overrun"
	SIX->DESCSPA:="Proposta+Revisao+Tipo+Cod Overrun"
	SIX->DESCENG:="Proposal+Revision+Type+Cod Overrun"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z49 ordem 2 "+NL


Return(cTexto)

*-----------------------------*
Static Function AltZ42(cTexto)
*-----------------------------*
Local lIncSIX	:= .F.

//{SIX} - Índice
DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z424"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z42"
	SIX->ORDEM:="4"
	SIX->CHAVE:="Z42_FILIAL+Z42_TIPOFU+Z42_CPF"
	SIX->DESCRICAO:="Tipo Funcio+Cpf"
	SIX->DESCSPA:="Tipo Funcio+Cpf"
	SIX->DESCENG:="Tipo Funcio+Cpf"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z42 ordem 4 "+NL


Return(cTexto)


*-----------------------------------*
Static Function AtuTabStatus(cTexto)
*-----------------------------------*
DbSelectArea("Z45")
DbSetOrder(1)
if !DbSeek(xFilial("Z45")+"H")
	RecLock("Z45",.T.)
		Z45->Z45_CODIGO:= "H"
		Z45->Z45_LEGEND:= "Aguardando Pool"
	Z45->(MsUnlock())
endif

DbSelectArea("Z47")
DbSetOrder(1)
if !DbSeek(xFilial("Z47")+"H")
	RecLock("Z47",.T.)
		Z47->Z47_CODIGO	:= "H"
		Z47->Z47_ACAO	:= "Verificar (Pool)" 
		Z47->Z47_NOPC	:= "I"
	Z47->(MsUnlock())
endif

DbSelectArea("Z45")
DbSetOrder(1)
if !DbSeek(xFilial("Z45")+"I")
	RecLock("Z45",.T.)
		Z45->Z45_CODIGO:= "I"
		Z45->Z45_LEGEND:= "Informado Overrun"
	Z45->(MsUnlock())
endif

DbSelectArea("Z47")
DbSetOrder(1)
if !DbSeek(xFilial("Z47")+"I")
	RecLock("Z47",.T.)
		Z47->Z47_CODIGO	:= "I"
		Z47->Z47_ACAO	:= "Informar Overrun" 
		Z47->Z47_NOPC	:= "J"
	Z47->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"H"+"01"+"H")
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "H"
		Z44->Z44_ITEM	:= "01" 
		Z44->Z44_CODACA	:= "H"
		Z44->Z44_DESCRI	:= "Verificar (Pool)"
	Z44->(MsUnlock())
endif

DbSelectArea("Z46")
DbSetOrder(1)
if DbSeek(xFilial("Z46")+"8"+"01"+"A")
	RecLock("Z46",.F.)
		Z46->Z46_CODLEG	:= "H"
		Z46->Z46_DESCRI	:= "Aguardando Pool"
	Z46->(MsUnlock())
endif

DbSelectArea("Z46")
DbSetOrder(1)
if !DbSeek(xFilial("Z46")+"H"+"01"+"A")
	RecLock("Z46",.T.)
		Z46->Z46_CODACA	:= "H"
		Z46->Z46_ITEM	:= "01" 
		Z46->Z46_CODLEG	:= "A"
		Z46->Z46_DESCRI	:= "Final Liberada"
	Z46->(MsUnlock())
endif

DbSelectArea("Z47")
DbSetOrder(1)
if !DbSeek(xFilial("Z47")+"J")
	RecLock("Z47",.T.)
		Z47->Z47_CODIGO	:= "J"
		Z47->Z47_ACAO	:= "Enviar Draft Pool"
		Z47->Z47_NOPC	:= "2"
	Z47->(MsUnlock())
endif

DbSelectArea("Z46")
DbSetOrder(1)
if !DbSeek(xFilial("Z46")+"J"+"01"+"J")
	RecLock("Z46",.T.)
		Z46->Z46_CODACA	:= "J"
		Z46->Z46_ITEM	:= "01"
		Z46->Z46_CODLEG	:= "J"
		Z46->Z46_DESCRI	:= "Draft Aguardando Pool"
	Z46->(MsUnlock())
endif

DbSelectArea("Z45")
DbSetOrder(1)
if !DbSeek(xFilial("Z45")+"J")
	RecLock("Z45",.T.)
		Z45->Z45_CODIGO:= "J"
		Z45->Z45_LEGEND:= "Draft Aguardando Pool"
	Z45->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"J"+"01"+"K")
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "J"
		Z44->Z44_ITEM	:= "01"
		Z44->Z44_CODACA	:= "K"
		Z44->Z44_DESCRI	:= "Draft Revisado Pool"
	Z44->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if DbSeek(xFilial("Z44")+"1"+"01"+"J")
	RecLock("Z44",.F.)
		Z44->Z44_CODLEG	:= "1"
		Z44->Z44_ITEM	:= "01"
		Z44->Z44_CODACA	:= "1"
		Z44->Z44_DESCRI	:= "Enviar Aprov. GT"
	Z44->(MsUnlock())
endif

DbSelectArea("Z47")
DbSetOrder(1)
if !DbSeek(xFilial("Z47")+"K")
	RecLock("Z47",.T.)
		Z47->Z47_CODIGO	:= "K"
		Z47->Z47_ACAO	:= "Verificar Draft (Pool)"
		Z47->Z47_NOPC	:= "I"
	Z47->(MsUnlock())
endif

DbSelectArea("Z46")
DbSetOrder(1)
if !DbSeek(xFilial("Z46")+"K"+"01"+"K")
	RecLock("Z46",.T.)
		Z46->Z46_CODACA	:= "K"
		Z46->Z46_ITEM	:= "01"
		Z46->Z46_CODLEG	:= "K"
		Z46->Z46_DESCRI	:= "Draft Revisado Pool"
	Z46->(MsUnlock())
endif

DbSelectArea("Z45")
DbSetOrder(1)
if !DbSeek(xFilial("Z45")+"K")
	RecLock("Z45",.T.)
		Z45->Z45_CODIGO:= "K"
		Z45->Z45_LEGEND:= "Draft Revisado Pool"
	Z45->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"K"+"01"+"3")
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "K"
		Z44->Z44_ITEM	:= "01"
		Z44->Z44_CODACA	:= "3"
		Z44->Z44_DESCRI	:= "Enviar Draft Cliente"
	Z44->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"K"+"02"+"6")
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "K"
		Z44->Z44_ITEM	:= "02"
		Z44->Z44_CODACA	:= "6"
		Z44->Z44_DESCRI	:= "Revisar"
	Z44->(MsUnlock())
endif

DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"K"+"03"+"5")
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "K"
		Z44->Z44_ITEM	:= "03"
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif

if Z46->(FieldPos("Z46_LEGSUB"))>0 .AND. Z46->(FieldPos("Z46_DESSUB"))>0
	DbSelectArea("Z46")
	DbSetOrder(1)
	if DbSeek(xFilial("Z46")+"2"+"01"+"3")
		RecLock("Z46",.F.)
			Z46->Z46_LEGSUB	:= "J"
			Z46->Z46_DESSUB	:= "Draft Aguardando Pool"
		Z46->(MsUnlock())
	endif
endif
	
cTexto += "Incluido/alterados legendas nas tabelas Z54,Z45,Z46,Z47 "+NL

Return


*-----------------------------------*
Static Function AtuRevCan(cTexto)
*-----------------------------------*
//Status Draft
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"1"+"05"+"5")     //Encerrar proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "1"
		Z44->Z44_ITEM	:= "05" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Aprovado GT
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"3"+"04"+"5")     //Encerrar proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "3"
		Z44->Z44_ITEM	:= "04" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Reprovado GT
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"4"+"02"+"5")     //Encerrar proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "4"
		Z44->Z44_ITEM	:= "02" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Draft Enviado
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"5"+"04"+"5")     //Encerrar proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "5"
		Z44->Z44_ITEM	:= "04" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Draft Aprovado
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"7"+"02"+"6")     //Revisar
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "7"
		Z44->Z44_ITEM	:= "02" 
		Z44->Z44_CODACA	:= "6"
		Z44->Z44_DESCRI	:= "Revisar"
	Z44->(MsUnlock())
endif
//Status Draft Aprovado
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"7"+"03"+"5")     //Encerrar Proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "7"
		Z44->Z44_ITEM	:= "03" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Final Liberada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"A"+"04"+"5")     //Encerrar Proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "A"
		Z44->Z44_ITEM	:= "04" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Final Enviada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"B"+"03"+"6")     //Revisar
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "B"
		Z44->Z44_ITEM	:= "03" 
		Z44->Z44_CODACA	:= "6"
		Z44->Z44_DESCRI	:= "Revisar"
	Z44->(MsUnlock())
endif
//Status Final Enviada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"B"+"04"+"5")     //Encerrar Proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "B"
		Z44->Z44_ITEM	:= "04" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Final Aprovada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"D"+"02"+"6")     //Revisar
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "D"
		Z44->Z44_ITEM	:= "02" 
		Z44->Z44_CODACA	:= "6"
		Z44->Z44_DESCRI	:= "Revisar"
	Z44->(MsUnlock())
endif
//Status Final Aprovada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"D"+"03"+"5")     //Encerrar Proposta
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "D"
		Z44->Z44_ITEM	:= "03" 
		Z44->Z44_CODACA	:= "5"
		Z44->Z44_DESCRI	:= "Encerrar Proposta"
	Z44->(MsUnlock())
endif
//Status Final Aprovada
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"D"+"04"+"G")     //Alterar Tipo Faturamento
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "D"
		Z44->Z44_ITEM	:= "04" 
		Z44->Z44_CODACA	:= "G"
		Z44->Z44_DESCRI	:= "Alterar Tipo Faturamento"
	Z44->(MsUnlock())
endif
//Status Proposta Ganha
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"E"+"03"+"I")     //Informar Overrun
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "E"
		Z44->Z44_ITEM	:= "03" 
		Z44->Z44_CODACA	:= "I"
		Z44->Z44_DESCRI	:= "Informar Overrun"
	Z44->(MsUnlock())
endif
//Status Proposta Perdida
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"F"+"01"+"F")     //Alterar Socio/Gerente
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "F"
		Z44->Z44_ITEM	:= "01" 
		Z44->Z44_CODACA	:= "F"
		Z44->Z44_DESCRI	:= "Alterar Socio/Gerente"
	Z44->(MsUnlock())
endif
//Status Proposta Perdida
DbSelectArea("Z44")
DbSetOrder(1)
if !DbSeek(xFilial("Z44")+"C"+"01"+"F")     //Alterar Socio/Gerente
	RecLock("Z44",.T.)
		Z44->Z44_CODLEG	:= "C"
		Z44->Z44_ITEM	:= "01" 
		Z44->Z44_CODACA	:= "F"
		Z44->Z44_DESCRI	:= "Alterar Socio/Gerente"
	Z44->(MsUnlock())
endif

cTexto += "Incluido/alterados legendas de revisar e encerrar em todas as etapas na tabela Z44 "+NL

Return

*---------------------------------*
Static Function DeParaZ29(cTexto)
*---------------------------------*
Local cQry:= ""

if TCCanOpen(RETSQLNAME("Z29"))

	cQry+=" SELECT * FROM "+RETSQLNAME("Z54")+" Z54
	cQry+=" JOIN "+RETSQLNAME("Z55")+" Z55 ON Z54_NUMPRO=Z55_NUM AND Z54_REVISA=Z55_REVISA AND Z54_FILIAL=Z55_FILIAL
	cQry+=" WHERE Z54.D_E_L_E_T_='' AND Z55.D_E_L_E_T_=''
	cQry+=" AND Z54_FILIAL+Z54_NUMPRO+Z54_REVISA+Z54_CODIGO NOT IN (
	cQry+=" SELECT Z29_FILIAL+Z29_NUMPRO+Z29_REVISA+Z29_CODIGO FROM "+RETSQLNAME("Z29")+" Z29
	cQry+=" WHERE Z29.D_E_L_E_T_='')
	
	
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
	        
		if nRecCount >0
			QRYTEMP->(DbGoTop())
	
			While QRYTEMP->(!EOF())
			    RecLock("Z29",.T.)
					Z29->Z29_FILIAL:=QRYTEMP->Z54_FILIAL		    
					Z29->Z29_ITEM:="01"
					Z29->Z29_CODIGO:=QRYTEMP->Z54_CODIGO
					Z29->Z29_NUMPRO:=QRYTEMP->Z54_NUMPRO
					Z29->Z29_REVISA:=QRYTEMP->Z54_REVISA
					Z29->Z29_TPCTR:=QRYTEMP->Z55_TPCTR
					Z29->Z29_CODDIV:=QRYTEMP->Z54_CODDIV
					Z29->Z29_CODNAT:=QRYTEMP->Z54_CODNAT
					Z29->Z29_HORAPR:=QRYTEMP->Z54_HORAPR
					Z29->Z29_CUSTOT:=QRYTEMP->Z54_CUSTOT
					Z29->Z29_PRECOL:=QRYTEMP->Z54_PRECOL
					Z29->Z29_PRELSU:=QRYTEMP->Z54_PRELSU
					Z29->Z29_TAXAME:=QRYTEMP->Z54_TAXAME
					Z29->Z29_TXMESU:=QRYTEMP->Z54_TXMESU
					Z29->Z29_RECUPE:=QRYTEMP->Z54_RECUPE
					Z29->Z29_SOCIO:=QRYTEMP->Z55_SOCIO
					Z29->Z29_GERENT:=QRYTEMP->Z55_GERENT
					Z29->Z29_DTAINI:=STOD(QRYTEMP->Z54_DTAINI)
					Z29->Z29_DTAFIM:=STOD(QRYTEMP->Z54_DTAFIM)
					Z29->Z29_FILORI:=QRYTEMP->Z54_FILORI
			    Z29->(MsUnlock())
				
				QRYTEMP->(DbSkip())
			Enddo
		endif

cTexto += "Incluido serviços na tabela Z29 de acordo com a Z54 e Z55"+NL
endif

Return



*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*

Local lIncSX3	:= .F.

For i:=1 to len(aSX3)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(!DbSeek(aSX3[i][3]))
		lIncSX3:=.T.
	else
		lIncSX3:=.F.
	endif
	
	Reclock("SX3",lIncSX3)
	
		SX3->X3_ARQUIVO	:= aSX3[i][1]
		SX3->X3_ORDEM	:= aSX3[i][2]
		SX3->X3_CAMPO	:= aSX3[i][3]
		SX3->X3_TIPO    := aSX3[i][4]
		SX3->X3_TAMANHO := val(aSX3[i][5])
		SX3->X3_DECIMAL := val(aSX3[i][6])
	
		if FieldPos("X3_TITULO")>0
			SX3->X3_TITULO:= aSX3[i][7]
		endif
		if FieldPos("X3_TITSPA")>0
			SX3->X3_TITSPA:= aSX3[i][8]
		endif
		if FieldPos("X3_TITENG")>0
			SX3->X3_TITENG:= aSX3[i][9]
		endif
		if FieldPos("X3_DESCRIC")>0
			SX3->X3_DESCRIC:= aSX3[i][10]
		endif
		if FieldPos("X3_DESCSPA")>0
			SX3->X3_DESCSPA:= aSX3[i][11]
		endif
		if FieldPos("X3_DESCENG")>0
			SX3->X3_DESCENG:= aSX3[i][12]
		endif
	
		SX3->X3_PICTURE := aSX3[i][13]
		SX3->X3_VALID   := aSX3[i][14]
		SX3->X3_USADO   := aSX3[i][15]
		SX3->X3_RELACAO := aSX3[i][16]
		SX3->X3_F3      := aSX3[i][17]
		SX3->X3_NIVEL   := val(aSX3[i][18])
		SX3->X3_RESERV  := aSX3[i][19]
		SX3->X3_CHECK   := aSX3[i][20]
		SX3->X3_TRIGGER := aSX3[i][21]
		SX3->X3_PROPRI  := aSX3[i][22]
		SX3->X3_BROWSE  := aSX3[i][23]
		SX3->X3_VISUAL  := aSX3[i][24]
		SX3->X3_CONTEXT := aSX3[i][25]
		SX3->X3_OBRIGAT := aSX3[i][26]
		SX3->X3_VLDUSER := aSX3[i][27]
		SX3->X3_CBOX    := aSX3[i][28]
		SX3->X3_CBOXSPA := aSX3[i][29]
		SX3->X3_CBOXENG := aSX3[i][30]
		SX3->X3_PICTVAR := aSX3[i][31]
		SX3->X3_WHEN    := aSX3[i][32]
		SX3->X3_INIBRW  := aSX3[i][33]
		SX3->X3_GRPSXG  := aSX3[i][34]
		SX3->X3_FOLDER  := aSX3[i][35]
		SX3->X3_PYME    := aSX3[i][36]
		SX3->X3_CONDSQL := aSX3[i][37]
		SX3->X3_CHKSQL  := aSX3[i][38]
		SX3->X3_IDXSRV  := aSX3[i][39]
		SX3->X3_ORTOGRA := aSX3[i][40]
		SX3->X3_IDXFLD  := aSX3[i][41]
		SX3->X3_TELA    := aSX3[i][42]
		SX3->X3_AGRUP   := aSX3[i][43]
	
	SX3->(MsUnlock())

	if lIncSX3
		cTexto += "Incluido no SX3 - o campo:"+aSX3[i][3]+NL
	else
		cTexto += "Alterado no SX3 - o campo:"+aSX3[i][3]+NL
	endif
	
Next	

Return


*-----------------------------------*
Static Function CriaSx2(aSX2,cTexto)
*-----------------------------------*

Local lIncSX2	:= .F.

For i:=1 to len(aSX2)
	
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if SX2->(!DbSeek(aSX2[i][1]))
		lIncSX2:=.T.
	else
		lIncSX2:=.F.
	endif  
	
	Reclock("SX2",lIncSX2)

		SX2->X2_CHAVE	:= aSX2[i][1]
		SX2->X2_PATH	:= aSX2[i][2]
		SX2->X2_ARQUIVO	:= aSX2[i][3]
		SX2->X2_NOME	:= aSX2[i][4]
		if FieldPos("X2_NOMESPA")>0
			SX2->X2_NOMESPA	:= aSX2[i][5]
		endif
		
		if FieldPos("X2_NOMEENG")>0
			SX2->X2_NOMEENG	:= aSX2[i][6]
		endif
		SX2->X2_ROTINA	:= aSX2[i][7]
		SX2->X2_MODO	:= aSX2[i][8]
		SX2->X2_MODOUN	:= aSX2[i][9]
		SX2->X2_MODOEMP	:= aSX2[i][10]
		SX2->X2_DELET	:= val(aSX2[i][11])
		SX2->X2_TTS		:= aSX2[i][12]
		SX2->X2_UNICO	:= aSX2[i][13]
		SX2->X2_PYME	:= aSX2[i][14]
		SX2->X2_MODULO	:= val(aSX2[i][15])
		SX2->X2_DISPLAY	:= aSX2[i][16]
		SX2->X2_SYSOBJ	:= aSX2[i][17]
		SX2->X2_USROBJ	:= aSX2[i][18]
	
	SX2->(MsUnlock())

	if lIncSX2
		cTexto += "Incluido no SX2 - a tabela:"+aSX2[i][1]+NL
	else
		cTexto += "Alterado no SX2 - a tabela:"+aSX2[i][1]+NL
	endif
	
Next	

Return

*-----------------------------------*
Static Function CriaSix(aSix,cTexto)
*-----------------------------------*

Local lIncSix	:= .F.

For i:=1 to len(aSix)

	DbSelectArea("SIX")
	SIX->(DbSetOrder(1))
	if SIX->(!DbSeek(PADR(aSix[i][1],3)+aSix[i][2]))
		lIncSIX:=.T.
	else
		lIncSIX:=.F.
	endif
	
	Reclock("SIX",lIncSIX)
		
		SIX->INDICE		:= aSix[i][1]
		SIX->ORDEM		:= aSix[i][2]
		SIX->CHAVE  	:= aSix[i][3]
		SIX->DESCRICAO  := aSix[i][4]
		SIX->DESCSPA	:= aSix[i][5]
		SIX->DESCENG	:= aSix[i][6]
		SIX->PROPRI		:= aSix[i][7]
		SIX->&('F3')	:= aSix[i][8]
		SIX->NICKNAME	:= aSix[i][9]
		SIX->SHOWPESQ	:= aSix[i][10]

	SIX->(MsUnlock())	
	
	if lIncSix
		cTexto += "Incluido no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	else
		cTexto += "Alterado no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	endif
	
Next

Return

*-----------------------------------*
Static Function CriaSx7(aSX7,cTexto)
*-----------------------------------*

Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(!DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))
		lIncSX7:=.T.
	else
		lIncSX7:=.F.
	endif
	
	Reclock("SX7",lIncSX7)
	
		SX7->X7_CAMPO	:= aSX7[i][1]
		SX7->X7_SEQUENC	:= aSX7[i][2]
		SX7->X7_REGRA	:= aSX7[i][3]
		SX7->X7_CDOMIN	:= aSX7[i][4]
		SX7->X7_TIPO	:= aSX7[i][5]
		SX7->X7_SEEK	:= aSX7[i][6]
		SX7->X7_ALIAS	:= aSX7[i][7]
		SX7->X7_ORDEM	:= val(aSX7[i][8])
		SX7->X7_CHAVE	:= aSX7[i][9]
		SX7->X7_CONDIC	:= aSX7[i][10]
		SX7->X7_PROPRI	:= aSX7[i][11]

	SX7->(MsUnlock())	
	
	if lIncSX7
		cTexto += "Incluido no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	else
		cTexto += "Alterado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	endif
	
Next 

Return

*-----------------------------------*
Static Function CriaSxb(aSXB,cTexto)
*-----------------------------------*

Local lIncSXB	:= .F.

For i:=1 to len(aSXB)

	DbSelectArea("SXB")
	SXB->(DbSetOrder(1))
	if SXB->(!DbSeek(PADR(alltrim(aSXB[i][1]),6)+PADR(alltrim(aSXB[i][2]),1)+PADR(alltrim(aSXB[i][3]),2)+aSXB[i][4]))
		lIncSXB:=.T.
	else
		lIncSXB:=.F.
	endif
	
	Reclock("SXB",lIncSXB)
	
		SXB->XB_ALIAS	:= aSXB[i][1]
		SXB->XB_TIPO	:= aSXB[i][2]
		SXB->XB_SEQ		:= aSXB[i][3]
		SXB->XB_COLUNA	:= aSXB[i][4]
		SXB->XB_DESCRI	:= aSXB[i][5]
		SXB->XB_DESCSPA	:= aSXB[i][6]
		SXB->XB_DESCENG	:= aSXB[i][7]
		SXB->XB_CONTEM	:= aSXB[i][8]
		SXB->XB_WCONTEM	:= aSXB[i][9]

	SXB->(MsUnlock())	
	
	if lIncSXB
		cTexto += "Incluido no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	else
		cTexto += "Alterado no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	endif
	
Next

Return 

*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*

Local lIncSX6	:= .F.

For i:=1 to len(aSX6)

	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	if SX6->(!DbSeek(PADR(alltrim(aSX6[i][1]),2)+PADR(alltrim(aSX6[i][2]),10)))
		lIncSX6:=.T.
	else
		lIncSX6:=.F.
	endif
	
	Reclock("SX6",lIncSX6)

		SX6->X6_FIL		:=aSX6[i][1]
		SX6->X6_VAR		:=aSX6[i][2]
		SX6->X6_TIPO	:=aSX6[i][3]
		SX6->X6_DESCRIC	:=aSX6[i][4]
		if FieldPos("X6_DSCSPA")>0
			SX6->X6_DSCSPA	:=aSX6[i][5]
		endif
		if FieldPos("X6_DSCENG")>0
			SX6->X6_DSCENG	:=aSX6[i][6]
		endif
		SX6->X6_DESC1	:=aSX6[i][7]
		if FieldPos("X6_DSCSPA1")>0
			SX6->X6_DSCSPA1	:=aSX6[i][8]
		endif
		if FieldPos("X6_DSCENG1")>0
			SX6->X6_DSCENG1	:=aSX6[i][9]
		endif
		SX6->X6_DESC2	:=aSX6[i][10]
		if FieldPos("X6_DSCSPA2")>0
			SX6->X6_DSCSPA2	:=aSX6[i][11]
		endif
		if FieldPos("X6_DSCENG2")>0
			SX6->X6_DSCENG2	:=aSX6[i][12]
		endif
		SX6->X6_CONTEUD	:=aSX6[i][13]
		SX6->X6_CONTSPA	:=aSX6[i][14]
		SX6->X6_CONTENG	:=aSX6[i][15]
		SX6->X6_PROPRI	:=aSX6[i][16]
		SX6->X6_PYME	:=aSX6[i][17]
		SX6->X6_VALID	:=aSX6[i][18]
		SX6->X6_INIT	:=aSX6[i][19]
		SX6->X6_DEFPOR	:=aSX6[i][20]
		SX6->X6_DEFSPA	:=aSX6[i][21]
		SX6->X6_DEFENG	:=aSX6[i][22]

	SX6->(MsUnlock())	
	
	if lIncSX6
		cTexto += "Incluido no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	else
		cTexto += "Alterado no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	endif
	
Next

Return

*-----------------------------------*
Static Function DeletSx7(aSX7,cTexto)
*-----------------------------------*
Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))

		Reclock("SX7",.F.)
	    	SX7->(DbDelete())
		SX7->(MsUnlock())	
		
		cTexto += "Deletado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	endif
	
Next 

Return