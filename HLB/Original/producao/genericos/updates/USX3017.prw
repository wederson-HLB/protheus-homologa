#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"

/*
Funcao      : USX3017
Objetivos   : Alteração do X3_RESERV do campos A2_PAIS para todos os moulos.
Autor       : Jean Victor Rocha
Data/Hora   : 18/06/2012
*/
*----------------------*
User Function USX3017(o)
*----------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
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

*-----------------------*
 Static Function AtuSX3()
*-----------------------*
Local cTexto  := ''
Local cReserv := '' 
Local aEstrut :={}
Local aSX3    :={}
Local cAlias  := '' 

Begin Sequence
   aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" 	,;
           	   "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  	,;
        	   "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER"	,;
        	   "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" , "X3_PYME"	,;
        	   "X3_CONDSQL","X3_CHKSQL"	,"X3_IDXSRV" ,"X3_ORTOGRA","X3_IDXFLD" ,"X3_TELA"   }

aAdd(aSx3, {"SE2","65","E2_NUMLIQ"	,"C",6,0,"No.Liquidaç.","Nº Liquidac.","Liquida No.","Número da Liquidação","Numero de la liquidacion","Liquidation Number","@!","","€€€€€€€€€€€€€€€","","",1,"†À","","","","","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SE2","66","E2_BCOCHQ"	,"C",3,0,"Bco Cheque","Bco. Cheque","Ch. Bank","Banco Cheque Liquidac.","Banco Cheque Liquidac.","Settlement Check Bank","@!","","€€€€€€€€€€€€€€€","","",1,"–€","","","","N","","","","","","","","","","","007","","S","","","N","N","N",""})
aAdd(aSx3, {"SE2","67","E2_AGECHQ"	,"C",5,0,"Agência Cheq","Agencia Cheq","Ch. B. Off.","Agência Cheque Liquidac.","Agencia Cheque Liquidac.","Sett. Check Bank Office","@!","","€€€€€€€€€€€€€€€","","",1,"–€","","","","N","","","","","","","","","","","008","","S","","","N","N","N",""})
aAdd(aSx3, {"SE2","68","E2_CTACHQ"	,"C",10,0,"Cta Cheque","Cta Cheque","Ch. C. Acc.","Conta Cheque Liduidac.","Cuenta Cheque Liduidac.","Sett. Check Curr. Account","@!","","€€€€€€€€€€€€€€€","","",1,"–€","","","","N","","","","","","","","","","","009","","S","","","N","N","N",""})
aAdd(aSx3, {"SE2","F9","E2_CIDE"	,"N",14,2,"Cide","Cide","CIDE","Valor do CIDE","Valor del CIDE","CIDE Value","@E 999,999,999.99","","€€€€€€€€€€€€€€€","","",1,"€€","","","","","","","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G2","E2_RETCNTR"	,"N",15,2,"Retencao Ctr","Retenc Ctr","Contr. Reten","Retencao de Contrato","Retencion de Contrato","Contract Retention","@E 999,999,999.99","","€€€€€€€€€€€€€€ ","0","",1,"†€","","","","N","A","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G3","E2_MDDESC"	,"N",15,2,"Desconto Ctr","Descuen Ctr","Contr Disc","Desconto de Contrato","Descuento de Contrato","Contract Discount","@E 999,999,999.99","","€€€€€€€€€€€€€€ ","0","",1,"†€","","","","N","A","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G4","E2_MDBONI"	,"N",15,2,"Bonific Ctr","Bonific Ctr","Contr Bonus","Bonificação de Contrato","Bonificacion de Contrato","Contract Bonus","@E 999,999,999.99","","€€€€€€€€€€€€€€ ","0","",1,"†€","","","","N","A","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G5","E2_MDMULT"	,"N",15,2,"Multa Ctr","Multa Ctr","Contr Fine","Multa de Contrato","Multa de Contrato","Contract Fine","@E 999,999,999.99","","€€€€€€€€€€€€€€ ","0","",1,"†€","","","","N","A","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G6","E2_PARCAGL"	,"C",1,0,"Parc.Aglut.","Cuota Agrup.","Grp.Install.","Parcelea aglutinadora","Cuota agrupadora","Grouping installment","@!","","€€€€€€€€€€€€€€€","","",1,"žÀ","","","","","","","","","","","","","","","011","","S","","","N","N","N",""})
aAdd(aSx3, {"SE2","G7","E2_CODINS"	,"C",4,0,"Cod Ret INSS","Cod Ret INSS","INSS Wth Cod","Cod Retenção INSS","Cod Retencion INSS","INSS Withholding Code","","","€€€€€€€€€€€€€€ ","","38",1,"„€","","","","","","","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SE2","G8","E2_PARCCID"	,"C",1,0,"Parc. CIDE","Cuota. CIDE","CIDE Inst.","Parcela do imposto","Cuota del impuesto","Tax Installment","@!","","€€€€€€€€€€€€€€€","","",1,"€€","","","","","","","","","","","","","","","011","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","08","RC_HORINFO"	,"N",6,2,"Horas Inform","Horas Inform","Hrs.Informed","Horas Informadas","Horas Informadas","Hours Informed","@E 999.99","Gp090Pula(.T.) .and. Positivo()","€€€€€€€€€€€€€€€","","",1,"œ€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","10","RC_VALINFO"	,"N",12,2,"Valor Inform","Valor Inform","Informed Vl.","Valor Informado","Valor Informado","Informed Value","@R 999,999,999.99","Positivo()","€€€€€€€€€€€€€€€","","",1,"œ€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","12","RC_VNAOAPL"	,"N",12,2,"Vl Nao Aplic","Vl No Aplic","Not Appl.Vl.","Valor Näo aplicado","Valor Näo aplicado","Not Applicable Value","@R 999,999,999.99","","€€€€€€€€€€€€€€€","","",1,"„€","","","","N","V","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","14","RC_DTREF"	,"D",8,0,"Dt. Ref.","Fch. Ref.","Ref.Date","Data Referencia","Fecha Referencia","Reference Date","@D","","€€€€€€€€€€€€€€€","RcDtRefInit()","",1,"†€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","21","RC_PROCES"	,"C",5,0,"Cod Processo","Cod Proceso","Process Code","Codigo Processo","Codigo Proceso","Process Code","","","€€€€€€€€€€€€€€€","RcProcesInit()","",1,"†€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","22","RC_PERIODO"	,"C",6,0,"Cod. Periodo","Cod. Periodo","Period Code","Codigo Periodo","Codigo Periodo","Period Code","","","€€€€€€€€€€€€€€€","RcPeriodoInit()","",1,"†€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","23","RC_POSTO"	,"C",9,0,"Cod. Posto","Cod. Puesto","Posit. Code","Cod. Posto","Cod. Puesto","Position Code","@!","","€€€€€€€€€€€€€€€","RcPostoInit()","",1,"†€","","","","N","V","R","","","","","","","","","026","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","24","RC_NUMID"	,"C",20,0,"Num.Identif.","Nº Identif.","Identif.No.","Numero Identificacao","Numero Identificacion","Identification Number","","","€€€€€€€€€€€€€€€","","",1,"†€","","","","N","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","25","RC_ROTEIR"	,"C",3,0,"Roteiro","Procedimient","Route","Roteiro","Procedimiento","Route","@!","","€€€€€€€€€€€€€€€","RcRoteirInit()","",1,"„€","","","","","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRC","26","RC_DEPTO"	,"C",9,0,"Cod. Depto.","Cod. Depto.","Dep. Code","Cod. Departamento","Cod. Departamento","Department Code","@!","EXISTCPO('SQB')","€€€€€€€€€€€€€€€","RcDeptoInit()","SQB",1,"†À","","","","S","A","R","","","","","","","","","025","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","02","CT2_CODCLI"	,"C",6,0,"Cód. Cliente","Cod. Cliente","Cust. Code","Código do Cliente da Cont","Cod del Cliente de la Cue","Customer Code","@!","","€€€€€€€€€€€€€€€","","SA1",1,"€€","","","","","","","","","","","","","","","001","","S","","","S","N","N",""})
aAdd(aSx3, {"CT2","03","CT2_CODFOR"	,"C",6,0,"Cód. Fornec.","Cod. Prov.","Sup. Code","Código do Fornecedor","Codigo del Proveedor","Supplier Code","@!","","€€€€€€€€€€€€€€€","","SA2",1,"€€","","","","","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","69","CT2_SEQIDX"	,"C",5,0,"Seq Chv Unic","Seq Clv Unic","Uni.Seq.Key","Sequencial Chave Unica","Alternativa habilitada","Unique Sequential Key","@!","","€€€€€€€€€€€€€€€","","",1,"„€","","","","N","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","70","CT2_CONFST"	,"C",1,0,"Status Conf.","Est. verif.","Chec. Status","Status Conferência","Estatus verificacion","Status of Checking","","","€€€€€€€€€€€€€€ ","","",1,"ÆÀ","","","","S","A","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","71","CT2_OBSCNF"	,"C",40,0,"Obs Conf","Obs Conf","Chec. Notes","Observação","Observacion","Notes","","","€€€€€€€€€€€€€€€","","",1,"ÆÀ","","","","S","A","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","73","CT2_USRCNF"	,"C",15,0,"Usuario Conf","Usuario Ver.","User Check","Usuario conferente","Usuario verificador","Checking User","","","€€€€€€€€€€€€€€ ","","",1,"ÆÀ","","","","N","V","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","74","CT2_DTCONF"	,"D",8,0,"Data Conf","Fecha Verif.","Check date","Daa Conferencia","Fecha verificacion","Check date","","","€€€€€€€€€€€€€€ ","","",1,"ÆÀ","","","","N","V","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CT2","75","CT2_HRCONF"	,"C",10,0,"Hora Conf","Hora Verif.","Check. Time","Hora Confenrecia","Hora de verificacion","Time for Checking","","","€€€€€€€€€€€€€€ ","","",1,"ÆÀ","","","","N","V","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"CN9","58","CN9_DESCRI"	,"C",40,0,"Descrição","Descripcion","Description","Descritivo do Contrato","Descriptivo del Contrato","Contract Description","@!","","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","59","CN9_END"	,"C",40,0,"Endereço","Direccion","Address","Endereço","Direccion","Address","@!","","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","60","CN9_MUN"	,"C",15,0,"Município","Municipio","City","Município","Municipio","City","@!","","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","61","CN9_BAIRRO"	,"C",20,0,"Bairro","Barrio","District","Bairro","Barrio","District","@!","","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","62","CN9_EST"	,"C",2,0,"Estado","Estado","State","Estado","Estado","State","@!","","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","S","","N","A","R","","","","","","","","","010","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","63","CN9_ESTADO"	,"C",20,0,"Nome Estado","Nombre Estad","State name","Nome Estado","Nombre Estado","State name","@!S20","","€€€€€€€€€€€€€€ ","If(!INCLUI,Posicione('SX5',1,xFilial('SX5')+ '12' + CN9->CN9_EST,'X5DESCRI()'),'')","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","64","CN9_ALCISS"	,"N",6,2,"Aliq. ISS","Alic. ISS","ISS rate","Aliquota ISS","Alicuota ISS","ISS rate","@E 999.99","Positivo()","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","65","CN9_INSSMO"	,"N",6,2,"Base INSS MO","Base INSS MO","L.F.INSS Bas","Base INSS Mao-de-Obra","Base INSS Mano de Obra","Labor force INSS base","@E 999.99","Positivo()","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","S","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"CN9","66","CN9_INSSME"	,"N",6,2,"Base ME","Base ME","ME base","Base Material","Base Material","Material base","@E 999.99","Positivo()","€€€€€€€€€€€€€€ ","","",1,"ÖÀ","","S","","N","A","R","","","","","","","","","","2","N","","","N","N","N",""})
aAdd(aSx3, {"SRD","07","RD_HORINFO"	,"N",9,2,"Horas Inform","Horas Inform","Hr.Informed","Horas Informadas","Horas Informadas","Informed Hours","@E 999999.99","Positivo()","€€€€€€€€€€€€€€€","","",1,"„€","","S","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","09","RD_VALINFO"	,"N",12,2,"Valor Inform","Valor Inform","Informed Vl.","Valor Informado","Valor Informado","Informed Value","@R 999,999,999.99","Positivo()","€€€€€€€€€€€€€€€","","",1,"„€","","S","","N","A","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SRD","11","RD_VNAOAPL"	,"N",12,2,"Vl Nao Aplic","Vl No Aplic","Not Appl.Vl.","Valor Nao Aplicado","Valor Nao Aplicado","Not Applicable Value","@R 999,999,999.99","","€€€€€€€€€€€€€€€","","",1,"„€","","","","N","V","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","24","RD_PROCES"	,"C",5,0,"Cod Processo","Cod Proceso","Process Code","Codigo Processo","Codigo Proceso","Process Code","","","€€€€€€€€€€€€€€€","","",1,"†€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","25","RD_PERIODO"	,"C",6,0,"Cod. Periodo","Cod. Periodo","Period Code","Codigo Periodo","Codigo Periodo","Period Code","","NaoVazio() .AND. gp120PerValid(mv_par06, mv_par07, M->RD_PERIODO)","€€€€€€€€€€€€€€€","","RCH",1,"„€","","S","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","26","RD_SEMANA"	,"C",2,0,"Semana","Semana","Week","Semana da Verba","Semana del Concepto","Funds Week","99","","€€€€€€€€€€€€€€ ","","",1,"Ÿ€","","","","S","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","27","RD_ROTEIR"	,"C",3,0,"Roteiro","Procedimient","Route","Roteiro","Procedimiento","Route","@!","ExistCpo('SRY', M->RD_ROTEIR) .AND. gp120RotValid(M->RD_ROTEIR)","€€€€€€€€€€€€€€€","","SRY",1,"„€","","","","N","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","28","RD_DTREF"	,"D",8,0,"Dt. Refer.","Fcha. Refer.","Ref.Date","Data Referencia","Fecha Referencia","Reference Date","@D","NaoVazio()","€€€€€€€€€€€€€€€","","",1,"†€","","","","N","A","R","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","29","RD_POSTO"	,"C",9,0,"Cod. Posto","Cod. Puesto","Posit. Code","Codigo Posto","Codigo Puesto","Position Code","@!","","€€€€€€€€€€€€€€ ","","RCL",1,"†€","","","","N","V","R","","","","","","","","","026","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","30","RD_NUMID"	,"C",20,0,"Num. Identif","Nº Identif","Identif.No.","Numero de Identificacao","Numero de Identificacion","Identification Number","","","€€€€€€€€€€€€€€€","","",1,"„€","","","","N","","","","","","","","","","","","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","31","RD_DEPTO"	,"C",9,0,"Cod. Depto.","Cod. Depto.","Dep. Code","Cod. Departamento","Cod. Departamento","Department Code","@!","EXISTCPO('SQB')","€€€€€€€€€€€€€€€","","SQB",1,"†À","","","","S","A","R","","","","","","","","","025","","S","","","N","N","N",""})
aAdd(aSx3, {"SRD","32","RD_PLNUCO"	,"C",12,0,"Nr. Cobranca","Nº Cobranza","Collect.Nr.","Numero da Cobranca","Numero de la Cobranza","Collection Number","@!","","€€€€€€€€€€€€€€€","","",1,"€€","","","","N","V","R","","","","","","","","","","","N","","","N","N","N",""})
aAdd(aSx3, {"SRD","33","RD_CODB1T"	,"C",12,0,"Seq. Lancto.","Sec. Regist.","Entry Seq.","Sequencia Lancamento","Secuencia Registro","Entry Sequence","@!","","€€€€€€€€€€€€€€€","","",1,"€€","","","","N","V","R","","","","","","","","","","","N","","","N","N","N",""})

ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))  
For i:=1 to Len(aSx3)
	//Verificar se o campo esta duplicado
	If SX3->(DbSeek(aSX3[i,3]))                    
		n:= 0
		While SX3->(!EOF()) .and. ALLTRIM(SX3->X3_CAMPO) == ALLTRIM(aSX3[i,3])
			n++
			SX3->(DbSkip())
		EndDo
	EndIf
	
	//Se estiver duplicado apaga os dois.
	If n > 1
		If SX3->(DbSeek(aSX3[i,3]))                    
			While SX3->(!EOF()) .and. ALLTRIM(SX3->X3_CAMPO) == ALLTRIM(aSX3[i,3])
				SX3->(RecLock("SX3",.F.))
				SX3->(DbDelete())
				SX3->(MsUnlock())					
				SX3->(DbSkip())
			EndDo
		EndIf
	EndIf
	//Se não existir, cria
	If !Empty(aSX3[i][1])
	  SX3->(DbSetOrder(2))
	  If SX3->(!DbSeek(aSX3[i,3]))
	     lSX3	:= .T.
		 If !(aSX3[i,1]$cAlias)
			cAlias += aSX3[i,1]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		 EndIf
		 RecLock("SX3",.T.)
		 For j:=1 To Len(aSX3[i])
			 If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
			 EndIf
		 Next j
		 DbCommit()
		 MsUnlock()
	 	 IncProc("Atualizando Dicionario de Dados...")
	 	 cTexto += 'Campo '+aSX3[i][3]+' criados com sucesso. '+ NL
	  EndIf
   EndIf

Next

End Sequence

Return cTexto