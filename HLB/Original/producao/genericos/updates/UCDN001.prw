#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UCDN001   ºAutor  ³Eduardo C. Romanini º Data ³  16/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Update para criação da tabela CDN, utilizada na gravação    º±±
±±º          ³de arquivos do SPED.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------------*
User Function UCDN001(lAmbiente)
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


Local aChamados := { {05, {|| AtuCDN()}} } //05 - SIGAFAT

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
Static Function AtuCDN(oProcess)
*------------------------------*
Local cTexto := ""

Local nI := {}

Local aAtuCDN := {}

//Carrega a tabela para atualização.
aAdd(aArqUpd,"CDN")

//Carrega os dados da tabela.
aAdd(aAtuCDN,{'01070121','107 ','SUPORTE TECNICO EM INFORMATICA                              '})
aAdd(aAtuCDN,{'01520   ','701 ','ENGENHARIA, AGRONOMIA, ARQUITETURA, URBANISMO E CONGENERES  '})
aAdd(aAtuCDN,{'01880   ','1402','ASSISTENCIA TECNICA                                         '})
aAdd(aAtuCDN,{'01902   ','1708','PERICIAS, LAUDOS, EXAMES TECNICOS E ANALISES TECNICAS, INCLU'})
aAdd(aAtuCDN,{'02151   ','3101','SERVICOS TECNICOS EM EDIFICACOES, ELETRONICA, ELETROTECNICA,'})
aAdd(aAtuCDN,{'02186   ','3201','SERVICOS DE DESENHOS TECNICOS.                              '})
aAdd(aAtuCDN,{'02445   ','1601','TRANSPORTE DE BENS OU VALORES, DENTRO DO TERRITORIO DO MUNIC'})
aAdd(aAtuCDN,{'02496   ','1706','PROPAGANDA E PUBLICIDADE, INCLUSIVE PROMOCAO DE VENDAS, PLAN'})
aAdd(aAtuCDN,{'02658   ','101 ','ANALISE E DESENVOLVIMENTO DE SISTEMAS                       '})
aAdd(aAtuCDN,{'02666   ','102 ','PROGRAMACAO.                                                '})
aAdd(aAtuCDN,{'02682   ','103 ','PROCESSAMENTO DE DADOS, OUTROS SERVICOS DE INFORMATICA NAO R'})
aAdd(aAtuCDN,{'02690   ','104 ','ELABORACAO DE PROGRAMAS DE COMPUTADORES (SOFTWARE), INCLUSIV'})
aAdd(aAtuCDN,{'02798   ','105 ','RECRUTAMENTO, AGENCIAMENTO, SELECAO E COLOCACAO DE MAO-DE-OB'})
aAdd(aAtuCDN,{'02879   ','106 ','ASSESSORIA E CONSULTORIA EM INFORMATICA.                    '})
aAdd(aAtuCDN,{'02917   ','107 ','SUPORTE TECNICO EM INFORMATICA, INCLUSIVE INSTALACAO, CONFIG'})
aAdd(aAtuCDN,{'02933   ','108 ','PLANEJAMENTO, CONFECCAO, MANUTENCAO E ATUALIZACAO DE PAGINAS'})
aAdd(aAtuCDN,{'03085   ','201 ','SERVICOS DE PESQUISAS E DESENVOLVIMENTO DE QUALQUER NATUREZA'})
aAdd(aAtuCDN,{'03093   ','1701','ANALISE, EXAME, PESQUISA, COLETA, COMPILACAO E FORNECIMENTO '})
aAdd(aAtuCDN,{'03115   ','1701','ASSESSORIA OU CONSULTORIA DE QUALQUER NATUREZA, NAO CONTIDA '})
aAdd(aAtuCDN,{'03123   ','1702','TRADUCAO E INTERPRETACAO.                                   '})
aAdd(aAtuCDN,{'03158   ','1702','TELEMARKETING                                               '})
aAdd(aAtuCDN,{'03204   ','1711','ADMINISTRACAO EM GERAL, INCLUSIVE DE BENS E NEGOCIOS DE TERC'})
aAdd(aAtuCDN,{'03212   ','1711','ADMINISTRACAO DE IMOVEIS                                    '})
aAdd(aAtuCDN,{'03395   ','1716','AUDITORIA                                                   '})
aAdd(aAtuCDN,{'03620   ','1719','CONTABILIDADE, INCLUSIVE SERVICOS TECNICOS E AUXILIARES     '})
aAdd(aAtuCDN,{'03654   ','1719','CONSULTORIA E ASSESSORIA ECONOMICA OU FINANCEIRA            '})
aAdd(aAtuCDN,{'03751   ','1723','APRESENTACAO DE PALESTRAS, CONFERENCIAS, SEMINARIOS E CONGEN'})
aAdd(aAtuCDN,{'05762   ','802 ','OUTROS SERVICOS DE INSTRUCAO, TREINAMENTO, ORIENTACAO PEDAGO'})
aAdd(aAtuCDN,{'06009   ','1009','REPRESENTACAO DE QUALQUER NATUREZA, INCLUSIVE COMERCIAL.    '})
aAdd(aAtuCDN,{'06041   ','1010','DISTRIBUICAO DE BENS DE TERCEIROS                           '})
aAdd(aAtuCDN,{'06050   ','1001','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE PLANOS DE PREVI'})
aAdd(aAtuCDN,{'06084   ','1001','AGENCIAMENTO OU INTERMEDIACAO DE SEGUROS.                   '})
aAdd(aAtuCDN,{'06114   ','1001','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE PLANOS DE SAUDE'})
aAdd(aAtuCDN,{'06130   ','1001','CORRETAGEM DE SEGUROS                                       '})
aAdd(aAtuCDN,{'06157   ','1002','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE TITULOS EM GERA'})
aAdd(aAtuCDN,{'06173   ','1003','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE DIREITOS DE PRO'})
aAdd(aAtuCDN,{'06297   ','1005','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE BENS MOVEIS OU '})
aAdd(aAtuCDN,{'06297   ','1005','AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE BENS MOVEIS OU '})
aAdd(aAtuCDN,{'06394   ','1008','AGENCIAMENTO DE PUBLICIDADE E PROPAGANDA, INCLUSIVE O AGENCI'})
aAdd(aAtuCDN,{'06475   ','1704','RECRUTAMENTO, AGENCIAMENTO, SELECAO E COLOCACAO DE MAO-DE-OB'})
aAdd(aAtuCDN,{'06777   ','1213','PRODUCAO, MEDIANTE OU SEM ENCOMENDA PREVIA, DE EVENTOS, ESPE'})
aAdd(aAtuCDN,{'06939   ','1304','COMPOSICAO GRAFICA, FOTOCOMPOSICAO, CLICHERIA, ZINCOGRAFIA, '})
aAdd(aAtuCDN,{'07129   ','902 ','AGENCIAMENTO, ORGANIZACAO, PROMOCAO, INTERMEDIACAO E EXECUCA'})
aAdd(aAtuCDN,{'07285   ','1406','INSTALACAO E MONTAGEM DE APARELHOS, MAQUINAS E EQUIPAMENTOS,'})
aAdd(aAtuCDN,{'07315   ','1406','INSTALACAO E MONTAGEM INDUSTRIAL, PRESTADA AO USUARIO FINAL,'})
aAdd(aAtuCDN,{'07498   ','1401','CONSERTO, RESTAURACAO, MANUTENCAO E CONSERVACAO DE MAQUINAS,'})
aAdd(aAtuCDN,{'07579   ','1405','RESTAURACAO, RECONDICIONAMENTO, ACONDICIONAMENTO, PINTURA, B'})
aAdd(aAtuCDN,{'07765   ','301 ','CESSAO DE DIREITO DE USO DE MARCAS E DE SINAIS DE PROPAGANDA'})
aAdd(aAtuCDN,{'07927   ','1104','ARMAZENAMENTO, DEPOSITO, CARGA, DESCARGA, ARRUMACAO E GUARDA'})
aAdd(aAtuCDN,{'07960   ','2002','SERVICOS AEROPORTUARIOS, UTILIZACAO DE AEROPORTO, MOVIMENTAC'})
aAdd(aAtuCDN,{'08021121','802 ','ENSINO DE IDIOMAS                                           '})
aAdd(aAtuCDN,{'08176   ','1208','FEIRAS, EXPOSICOES, CONGRESSOS E CONGENERES.                '})
aAdd(aAtuCDN,{'10020321','1002',' AGENCIAMENTO, CORRETAGEM E INTERMEDIACAO DE QUALQUER NATURE'})
aAdd(aAtuCDN,{'10050321','1005','INTERMEDIACAO DE NEGOCIOS                                   '})
aAdd(aAtuCDN,{'10090121','1009','REPRESENTACAO DE QUALQUER NATUREZA                          '})
aAdd(aAtuCDN,{'10100121','1010','DISTRIBUICAO DE BENS DE TERCEIROS                           '})
aAdd(aAtuCDN,{'170101  ','1701','ASSESSORIA OU CONSULTORIA DE QUALQUER NATUREZA, NAO ESPECIFI'})
aAdd(aAtuCDN,{'17060321','1706','MARKETING                                                   '})
aAdd(aAtuCDN,{'171601  ','1716','AUDITORIA                                                   '})
aAdd(aAtuCDN,{'171901  ','1719','CONTABILIDADE, INCLUSIVE SERVICOS TECNICOS E AUXILIARES     '})
aAdd(aAtuCDN,{'172001  ','1701','CONSULTORIA E ASSESSORIA ECONOMICA OU FINANCEIRA            '})

//Apaga os registros da tabela.
cTabela := RetSqlName("CDN")
cAlias := "TMP"

USE (cTabela) ALIAS (cAlias) EXCLUSIVE NEW VIA "TOPCONN"
If NetErr()   
	MsgStop("Nao foi possivel abrir "+cTabela+" em modo EXCLUSIVO.")     
Else   
	ZAP   
	USE   
	MsgStop("Registros da tabela "+cTabela+" eliminados com sucesso.")
Endif

//Atualiza a tabela
For nI:=1 To Len(aAtuCDN)
	CDN->(RecLock("CDN",.T.))
    CDN->CDN_CODISS := aAtuCDN[nI][1]
    CDN->CDN_CODLST := aAtuCDN[nI][2]
    CDN->CDN_DESCR  := aAtuCDN[nI][3]
	CDN->(MsUnlock())
Next

//Carrega o log
cTexto += 'Tabela CDN atualizada com sucesso.' + CHR(13) + CHR(10)

Return cTexto
