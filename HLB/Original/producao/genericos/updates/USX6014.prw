#INCLUDE "Protheus.ch"
/*
Funcao      : USX6014
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do parâmetro MV_ALIQICM com alíquota de 4%, inclusão no SX5 da tabela S0 com as novas origens do produto e alteração
			  das Exceções Fiscais para as empresas que possuem é alterado o campo F7_ALIQEXT para 4%. 
Autor       : Renato Rezende
Data/Hora   : 21/12/2012
Revisao     :
Obs.        :
*/  
*--------------------------------*
User Function USX6014(lAmbiente)
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualização do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faça um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando preparação dos arquivos...",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

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


Local aChamados := { {05, {|| AtuSX6()}} } //05 - SIGAFAT

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
	  		    contidas no array aChamados para cada módulo. */

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next

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
Revisao     :
Obs.        :
*/ 
*---------------------------*
Static Function MyOpenSM0Ex()                 	
*---------------------------*
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
      Aviso( "Atencao !", "Não foi possível a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              



*------------------------------*
Static Function AtuSX6(oProcess)
*------------------------------*
Local cTexto := "" 
Local aDefine:= {}
Local i
Local lCriarReg := .T.
Local cDelimitador := ""
Local aTest := {}
Local lExiste := .F.
Local lSX5 := .F.
Local aSX5 :={}
Local aSX5Estrut:= { "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE"  ,"X5_DESCRI" ,"X5_DESCSPA","X5_DESCENG"}

IncProc("Atualizando Parametros!")

aAdd(aDefine, {"MV_ALIQICM"	,"4"})

SX6->(DbSetOrder(1))
For i:=1 to Len(aDefine)
	// Busca o registro ou posiciona no final
	SX6->(DbSeek(xFilial("SX6") + aDefine[i][1]))
	                                        
	If SX6->(RecLock("SX6", .F.))                       
		Do case
			Case at(",",SX6->X6_CONTEUD) <> 0
				cDelimitador:=","
			Case at("/",SX6->X6_CONTEUD) <> 0
				cDelimitador:="/"			
			Case at(";",SX6->X6_CONTEUD) <> 0    
				cDelimitador:=";"
		EndCAse
		aTest := Separa(Alltrim(SX6->X6_CONTEUD),cDelimitador,.f.)
	
		//Verifica se existe conteudo do parametro MV_ALIQICM
		If Alltrim(SX6->X6_CONTEUD) = ''
				SX6->X6_CONTEUD := aDefine[i][2]
				SX6->X6_CONTSPA := aDefine[i][2]
				SX6->X6_CONTENG := aDefine[i][2]
				SX6->(MSUNLOCK())
				cTexto += "Foi atualizado o paramentro " + aDefine[i][1] + " " +CHR(13)+CHR(10)

		//Verifica se o array aTest1 existe o conteudo com valor 4
		Else
			For j:=1 to Len(aTest)
				If aTest[j] == '4'
					lExiste := .T.
				EndIf
			Next j 
			//Se o arrays aTest retornar .F. irá adicionar o valor 4 no parametro MV_ALIQICM
	    	If !lExiste
				SX6->X6_CONTEUD := ALLTRIM(SX6->X6_CONTEUD)+cDelimitador+aDefine[i][2]
				SX6->X6_CONTSPA := ALLTRIM(SX6->X6_CONTSPA)+cDelimitador+aDefine[i][2]
				SX6->X6_CONTENG := ALLTRIM(SX6->X6_CONTENG)+cDelimitador+aDefine[i][2]
				SX6->(MSUNLOCK())
				cTexto += "Foi atualizado o paramentro " + aDefine[i][1] + " " +CHR(13)+CHR(10)
			Else
				cTexto += "Nao foi possivel atualizar o paramentro " + aDefine[i][1] + " " +CHR(13)+CHR(10)
			EndIf
					
		EndIf
	Else
		cTexto += "Nao foi possivel atualizar o paramentro " + aDefine[i][1] + " " +CHR(13)+CHR(10)
	EndIf
			
Next i


//Inclusão no SX5 dos novos códigos para a origem do produto


////////////////////////////////
//Criação de Tabelas Genéricas//
////////////////////////////////

//          "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE" ,"X5_DESCRI"                                               ,"X5_DESCSPA"       ,"X5_DESCENG"
aAdd(aSX5,{xFilial()    ,"S0"		 , "3"		 ,"NACIONAL, MERC OU BEM COM CONTEUDO DE IMPORT SUP A 40%"  ,"."				,"."})
aAdd(aSX5,{xFilial()	,"S0"		 , "4"		 ,"NACIONAL, DECRETO-LEI Nº 288/67"					    	,"."				,"."})
aAdd(aSX5,{xFilial()	,"S0"		 , "5"		 ,"NACIONAL, MERC OU BEM COM CONTEUDO DE IMPORT >= 40%"     ,"."				,"."})
aAdd(aSX5,{xFilial()	,"S0"		 , "6"		 ,"ESTRANGEIRA - IMPORTACAO DIRETA, SEM SIMILAR NACIONAL"   ,"."				,"."})
aAdd(aSX5,{xFilial()	,"S0"		 , "7"		 ,"ESTRANGEIRA - ADQ NO MERC INTERNO, SEM SIMILAR NACIONAL" ,"."				,"."})


///////////////////////////////////////////
//Inicio da Gravação de Tabelas Genéricas//
///////////////////////////////////////////

cAlias := ""   
   
ProcRegua(Len(aSX5))

DbSelectArea("SX5")
SX5->(DbSetOrder(1))

For i:= 1 To Len(aSX5)
	If !dbSeek(aSX5[i,1]+aSX5[i,2]+aSX5[i,3])
		
		If !(aSX5[i,2]$cAlias)
			lSX5	:= .T.
			cAlias  += aSX5[i,2]+"/"
		EndIf
		
		RecLock("SX5",.T.)
		For j:=1 To Len(aSX5[i])

			If FieldPos(aSX5Estrut[j])>0 .And. aSX5[i,j] != NIL
				FieldPut(FieldPos(aSX5Estrut[j]),aSX5[i,j])
			EndIf

		Next j
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Dicionario de Dados...")
	Endif
Next i

If lSX5
	cTexto += 'Foram incluídas as seguintes tabelas genéricas : ' + cAlias + CHR(13) + CHR(10)
Else
	cTexto += 'Nao foi possivel cadastrar os registros da tabela SX5 S0 ' + CHR(13) + CHR(10)
EndIf

//RRP - 26/12/2012 - Alteração na Tabela SF7 das aliquotas de ICMS para 4% das que exitirem dados.

nCount2 := 0 // Variável para verificar quantos registros há no intervalo 

SF7->(DbSetOrder(1)) // FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
SF7->(DbGoTop()) 

//Se encontrou registro na tabela SF7 é feita a atualização da aliquota.
SF7->(DbGoTop())
While SF7->(!EOF())
	If SF7->(RecLock("SF7", .F.))
		SF7->F7_ALIQEXT := 4
		SF7->(MsUnLock())
		nCount2++ // Incrementa a variável de controle de registros no intervalo 
	EndIf		
	SF7->(DbSkip())
End


If nCount2 > 0
	cTexto += 'Foram atualizadas a aliquota externas da SF7 para 4%' + CHR(13) + CHR(10)
Else
	cTexto += 'Empresa não existe exceção fiscal' + CHR(13) + CHR(10)
EndIf

Return cTexto