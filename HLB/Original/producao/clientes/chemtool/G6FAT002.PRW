#include "protheus.ch"

/*
Funcao      : G6FAT002
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Importar pedidos de venda, seguindo um padrão de layout abaixo, utilizando arquivo txt.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 09/03/2012    14:14
Módulo      : Faturamento
*/

//Layout txt - separação por ;
/*
Supplier Code					String	6	   	   		drped037.cuno
Supplier Part Number			String	16	   	   		drped034.itfo
Supplier Package Code			String	3		   		drped034.vaif
Qty Ordered						String	5	ZZZZ9  		drped038.qtso
Dealer Code (in the supplier)	String	10	   			drped033.clfo
Order Number					String	8		   		drped037.pefo
Order Creation Date				String	10	DD/MM/AAAA	drped037.dtcr
Days for payment				String	4		   		drped037.dipg
Value							String	9	ZZZ,ZZ9.99	drped038.valo
State Destination				String	3	   			tccom013.esta.l
Factor used						String	7	Z9.9999		drped038.fato
Discount percentage				String	5	Z9.99		drped037.pede
Delivery address CNPJ			String	17	999999999/9999-99	tccom013.cgcc.l & "/" & tccom013.cgce.l & "-" tccom013.cgcd.l
Dealer CNPJ 					String	17	999999999/9999-99	tccom010.cgcc.l & "/" & tccom010.cgce.l & "-" tccom010.cgcd.l
Payment condition				String	3		   		drped037.copg
Payment condition description	String	30		   		tcmcs013.dsca
*/

User Function G6FAT002()

if !cEmpAnt $ "G6/99"
	alert("Empresa não autorizada!")
	return
endif

Private cArqTxt := cGetFile("Arquivos| *.txt|", "Selecione o diretório",,,,;
                 GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE,.F.) 

Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}


If Empty(cArqTxt)
	Alert("Cancelado!")
	Return	
EndIf               
     
Processa({||GeraArq(cArqTxt)}, "Processando...")


Return

/*
Funcao      : GeraArq()  
Parametros  : cArqTxt
Retorno     : Nil
Objetivos   : Processar o arquivo selecionado
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/

Static Function GeraArq(cArqTxt)
Local nI
Local nUsado := 0
Local aButtons :={}

AADD(aButtons,{"NOTE", {|| Render(aCols)}, "Atualizar Sequencia",})

Private oDlg
Private oGetDados
Private lRefresh := .T.
Private aHeader := {}
Private aCols := {}
Private aAlter:={}
Private lCtrl:=.F.

ProcRegua(0)

/*++++++++Carrego SC5 no aHeader+++++++++*/

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SC5")
//C5_P_SCODE
While !Eof().And.(x3_arquivo=="SC5")
	If alltrim(SX3->X3_CAMPO) $ "C5_NUM/C5_TIPO/C5_LOJACLI/C5_CONDPAG/C5_EMISSAO/C5_LOJAENT/C5_P_SCODE" .or. alltrim(SX3->X3_CAMPO)=="C5_CLIENTE" .or. alltrim(SX3->X3_CAMPO)=="C5_CLIENT" //C5_P_SCODE
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(SX3->X3_TITULO),;
							 SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
		 					 SX3->X3_DECIMAL,;
		 					 "ALLWAYSTRUE()",;
		 					 SX3->X3_USADO,;
		 					 SX3->X3_TIPO,;
		 					 SX3->X3_ARQUIVO,;
		 					 SX3->X3_CONTEXT } )
        
        if SX3->X3_CAMPO=="C5_LOJACLI"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Cli Sistema"),;
								 "C5_TPM_D1",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

        endif
        if SX3->X3_CAMPO=="C5_LOJAENT"
			// +++++ Adicionando campos para visualização da descrição do cliente

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Cli Entrega"),;
								 "C5_TPM_D2",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

        endif
  
	if !alltrim(SX3->X3_CAMPO)=="C5_CLIENT" .AND. !alltrim(SX3->X3_CAMPO)=="C5_LOJAENT" .AND. !alltrim(SX3->X3_CAMPO)=="C5_P_SCODE"
		aadd(aAlter,SX3->X3_CAMPO)
	endif    

	Endif
	dbSkip()
Enddo

/*++++++++Carrego SC6 no aHeader+++++++++*/

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC6")

While !Eof().And.(SX3->X3_ARQUIVO=="SC6")
	//If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
								//"C6_ITEM/C6_PRODUTO/C6_UM/C6_PRCVEN/C6_QTDVEN/C6_QTDLIB/C6_VALOR/C6_TES/C6_LOCAL/C6_CF/C6_DESCRI/C6_P_GEOG"
	If alltrim(SX3->X3_CAMPO) $ "C6_ITEM/C6_PRODUTO/C6_PRCVEN/C6_QTDVEN/C6_QTDLIB/C6_VALOR/C6_TES/C6_CF/C6_DESCONT"
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(SX3->X3_TITULO),;
							 SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
		 					 SX3->X3_DECIMAL,;
		 					 "ALLWAYSTRUE()",;
		 					 SX3->X3_USADO,;
		 					 SX3->X3_TIPO,;
		 					 SX3->X3_ARQUIVO,;
		 					 SX3->X3_CONTEXT } )
		 					 
		 					 
		 					 
        if alltrim(SX3->X3_CAMPO)=="C6_QTDVEN"
			// +++++ Adicionando campos para visualização da descrição da quantidade da planilha
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Qtd Planilha"),;
								 "C6_TPM_D1",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

        endif
        if alltrim(SX3->X3_CAMPO)=="C6_PRODUTO"
			// +++++ Adicionando campos para visualização da descrição do produto
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Descricao"),;
								 "C6_TPM_D2",;
								 "@X  ",;
								 30,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

        endif
		 					 

	aadd(aAlter,SX3->X3_CAMPO)

	Endif
	dbSkip()
Enddo

/*++++++++ Montagem do aCols +++++++++*/

if MontaCols(nUsado,aHeader,@aCols,cArqTxt)
	Return
endif

/*++++++++ Definição da tela +++++++++*/

//oDlg := MSDIALOG():New(000,000,300,400, "Faturamento",,,,,,,,,.T.)
oDlg := MSDIALOG():New(000,000,700,1000, "Faturamento",,,,,,,,,.T.)
                               //500,800

//oGetDados := MsGetDados():New(05, 05, 145, 195, 3, "U_LINHAOK", "U_TUDOOK",;
//"+C5_NUM", .T., aAlter, , .F., 200, "U_FIELDOK49", "U_SUPERDEL",,;
//"U_DELOK", oDlg

                                    //250,400
oGetDados := MsGetDados():New(15, 05, 350, 500, 3, "AllwaysTrue()", "AllwaysTrue()",;
"+C5_ITEM", .T., aAlter, , .F., 200, "U_FIELDOKG6", "AllwaysTrue()",,;
"AllwaysTrue()", oDlg)


oGetDados:oBrowse:lUseDefaultColors := .F.
oGetDados:oBrowse:SetBlkBackColor({|| GETDCLR(aCols,n,aHeader,.F.)})

oDlg:bInit := {|| EnchoiceBar(oDlg, {|| iif(ValidaInfo(aCols,aHeader),Processa({||GravaDados(@aCols,aHeader,nUsado),"Processando..."}),"")    },{||oDlg:End()},,aButtons)}
oDlg:lCentered := .T.
oDlg:Activate()

Return 

/*
Funcao      : MontaCols()  
Parametros  : nUsado,aHeader,aCols
Retorno     : lSair
Objetivos   : Gerar o array acols, com as informações da tabela
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function MontaCols(nUsado,aHeader,aCols,cArqTxt)
Local lControl:=.T.
Local lSair:=.F.
Local cEstCli:=""
Local nTpALiq:=0
Local cCFOP:=""
Local dDtVenc
Local nDtDife                                        

Local nSeqItem:="00"//variável para sequencia do item

Local nAuxQtd:=0 //variável para controle da quantidade
Local nAuxPre:=0 //variável para controle do preco
Local nValTot:=0

FT_FUse(cArqTxt) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo


While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

    if lControl
	 	if !len(aLinha)==16
	 		Alert("O Arquivo selecionado não está no padrão para importação!")
	 		lSair:=.T.
	 		Return(lSair)
	 	endif
		lControl:=.F.
		loop
	endif    

	//nome cliente + PI + mapa  
	if empty(aLinha[5]) .and. empty(aLinha[8]) .and. empty(aLinha[9])
		exit
	endif   
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if ALLTRIM(aHeader[nI,2]) =="C5_NUM"
				aCols[Len(aCols),nI]:=alltrim(strzero(val(aLinha[6]),6))
			elseif ALLTRIM(aHeader[nI,2]) =="C5_CONDPAG"
				
				aCols[Len(aCols)][nI] := '050'

			elseif ALLTRIM(aHeader[nI,2]) =="C5_TIPO"
				aCols[Len(aCols),nI]:="N"
			elseif ALLTRIM(aHeader[nI,2]) =="C5_LOJACLI"
                //não faz nada no lojacli pois ja foi tratado no campo cliente *1
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_D1"
				//não faz nada no Temp_d1 pois ja foi tratado no campo cliente *2
			elseif ALLTRIM(aHeader[nI,2]) =="C5_LOJAENT"
                //não faz nada no lojaent pois ja foi tratado no campo cliente *4
			elseif ALLTRIM(aHeader[nI,2]) =="C5_TPM_D2"
				//não faz nada no Temp_d2 pois ja foi tratado no campo cliente *5
			elseif ALLTRIM(aHeader[nI,2]) =="C5_P_SCODE"
				//não faz nada no C5_P_SCODE pois ja foi tratado no campo cliente *6
//+++++++ tratamento para cliente +++++++++++//
			elseif ALLTRIM(aHeader[nI,2]) =="C5_CLIENTE"

                if !empty(alltrim(aLinha[1]))
					cQry:=" SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME FROM "+RETSQLNAME("SA1")+CRLF
					cQry+=" WHERE UPPER(A1_COD) = UPPER('"+alltrim(aLinha[1])+"') AND D_E_L_E_T_='' AND A1_FILIAL='"+xFilial("SA1")+"'
					
					if select("TRBCLI")>0
						TRBCLI->(DbCloseArea())
					endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCLI",.T.,.T.)
		
					COUNT TO nRecCount
	            else
		            nRecCount:=0
	            endif
	            
				if nRecCount>0
					TRBCLI->(DbGotop())
					aCols[Len(aCols),nI]:=TRBCLI->A1_COD

					//*1  tratamento para preencher a loja do cliente
					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJACLI"} )
					aCols[Len(aCols),nPosLoja]:=TRBCLI->A1_LOJA					
					//*2  tratamento para preencher a descrição do cliente no sistema
					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D1"} )
					aCols[Len(aCols),nPosNome]:=substr(TRBCLI->A1_NOME,1,30)
					//*6 tratamento para preencher o código do supplier
					nPosP_SCODE:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_P_SCODE"} )
					aCols[Len(aCols),nPosP_SCODE]:=TRBCLI->A1_COD

	            else
	            	aCols[Len(aCols),nI]:=CriaVar(aHeader[nI][2])

					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJACLI"} )
					aCols[Len(aCols),nPosLoja]:=CriaVar(aHeader[nPosLoja][2])

					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D1"} )
					aCols[Len(aCols),nPosNome]:=space(30)

					nPosP_SCODE:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_P_SCODE"} )
					aCols[Len(aCols),nPosP_SCODE]:=alltrim(aLinha[1])
	            endif
//+++++++ fim tratamento para cliente +++++++++++//

//+++++++ tratamento para cliente entrega +++++++++++//
			elseif ALLTRIM(aHeader[nI,2]) =="C5_CLIENT"

                if !empty(alltrim(aLinha[13]))
					
					cCGC:=cvaltochar(val(STRTRAN(STRTRAN(STRTRAN(aLinha[13],"."),"/"),"-")))
					
					cQry:=" SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME FROM "+RETSQLNAME("SA1")+CRLF
					cQry+=" WHERE UPPER(A1_CGC) LIKE UPPER('%"+cCGC+"%') AND D_E_L_E_T_='' AND A1_FILIAL='"+xFilial("SA1")+"'
					
					if select("TRBCLI")>0
						TRBCLI->(DbCloseArea())
					endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCLI",.T.,.T.)
		
					COUNT TO nRecCount
	            else
		            nRecCount:=0
	            endif
	            
				if nRecCount>0
					TRBCLI->(DbGotop())
					aCols[Len(aCols),nI]:=TRBCLI->A1_COD

					//*4  tratamento para preencher a loja do cliente entrega
					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJAENT"} )
					aCols[Len(aCols),nPosLoja]:=TRBCLI->A1_LOJA					
					//*5  tratamento para preencher a descrição do cliente de entrega no sistema 
					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D2"} )
					aCols[Len(aCols),nPosNome]:=substr(TRBCLI->A1_NOME,1,30)
					
	            else
	            	aCols[Len(aCols),nI]:=CriaVar(aHeader[nI][2])

					nPosLoja:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_LOJAENT"} )
					aCols[Len(aCols),nPosLoja]:=CriaVar(aHeader[nPosLoja][2])

					nPosNome:=aScan( aHeader, { |x| alltrim(x[2]) == "C5_TPM_D2"} )
					aCols[Len(aCols),nPosNome]:=space(30)

	            endif
//+++++++ fim tratamento para cliente entrega +++++++++++//

			//C6_ITEM/C6_PRODUTO/C6_UM/C6_PRCVEN/C6_QTDVEN/C6_VALOR/C6_TES/C6_LOCAL/C6_CF/C6_DESCRI/C6_P_GEOG
			elseif ALLTRIM(aHeader[nI,2]) =="C6_ITEM"			
				nSeqItem:=SOMA1(nSeqItem)
				aCols[Len(aCols),nI]:= nSeqItem
			elseif ALLTRIM(aHeader[nI,2]) =="C6_PRCVEN"							   
				nAuxPre:=val(strtran(strtran(aLinha[9],"."),",","."))
				aCols[Len(aCols),nI]:=nAuxPre
			elseif ALLTRIM(aHeader[nI,2]) =="C6_QTDVEN"
				nAuxQtd:=val(strtran(strtran(aLinha[4],"."),",","."))
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				if SB1->(DbSeek(xFilial("SB1")+alltrim(aLinha[2])))
					if !empty(SB1->B1_LOTVEN)
						nAuxQtd:=MRoundInt(int(nAuxQtd),SB1->B1_LOTVEN)	//função de arredondamento
					endif
				endif
				
				aCols[Len(aCols),nI]:=nAuxQtd
			elseif ALLTRIM(aHeader[nI,2]) =="C6_TPM_D1"
				aCols[Len(aCols),nI]:=aLinha[4]
			elseif ALLTRIM(aHeader[nI,2]) =="C6_QTDLIB"
				aCols[Len(aCols),nI]:=0
			elseif ALLTRIM(aHeader[nI,2]) =="C6_VALOR"
				nPos1:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_QTDVEN"} )
				nPos2:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_PRCVEN"} )
				
				nValTot:=ROUND(aCols[Len(aCols),nPos1]*aCols[Len(aCols),nPos2],2)

				aCols[Len(aCols),nI]:=nValTot

//+++++++ tratamento para TES +++++++++++//			
			elseif ALLTRIM(aHeader[nI,2]) =="C6_TES"
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
//+++++++ fim tratamento TES +++++++++++//
			elseif ALLTRIM(aHeader[nI,2]) =="C6_CF"
					aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])				
			elseif ALLTRIM(aHeader[nI,2]) =="C6_DESCONT"
					aCols[Len(aCols)][nI] :=val(aLinha[12])
			elseif ALLTRIM(aHeader[nI,2]) =="C6_PRODUTO"
					aCols[Len(aCols)][nI] :=aLinha[2]
					
					//*3 tratamento da descrição do produto
					DbSelectArea("SB1") 
					DbSetOrder(1)
					nPos3:=aScan( aHeader, { |x| alltrim(x[2]) == "C6_TPM_D2"} )
					if DbSeek(xFilial("SB1")+aLinha[2])
						aCols[Len(aCols)][nPos3] := SB1->B1_DESC						
					else
						aCols[Len(aCols),nPos3]:=space(30)
					endif
					
			elseif ALLTRIM(aHeader[nI,2]) =="C6_TPM_D2"
					//não faz nada pois já foi tratado no produto *3
			else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
	FT_FSkip() // Proxima linha
Enddo

Return(lSair)

/*
Funcao      : GravaDados()  
Parametros  : aCols,aHeader
Retorno     : Nil
Objetivos   : Executar o Msexecauto da rotina MATA410
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function GravaDados(aCols,aHeader,nUsado)

ProcRegua(0)

Private aDados:={}
Private aItem:={}
Private aItens:={}
Private aErros:={}
Private aGravado:={}
Private aAuxaCols:={}
Private lErro:=.F.
Private lInsCapa:=.T.

for j:=1 to len(aCols)
	
	if !aCols[j][len(aCols[j])]
		for i:=1 to len(aCols[j])-1
			if "C5_" $ aHeader[i][2] .AND. lInsCapa
				if !"C5_TPM" $ aHeader[i][2]
					AADD(aDados,{aHeader[i][2],	iif(valtype(aCols[j,i])=="C",alltrim(aCols[j,i]),aCols[j,i]),	nil})
			    endif
			else
				if !"C6_TPM" $ aHeader[i][2] .AND. !"C5_" $ aHeader[i][2]
					
						AADD(aItem,	{aHeader[i][2],	iif(valtype(aCols[j,i])=="C",alltrim(aCols[j,i]),aCols[j,i]),	nil})
				endif
			endif
		next
	endif

	if j<>len(aCols)
		if aCols[j][1]==aCols[j+1][1]
			AADD(aItens,aItem)
			aItem:={}
	    	lInsCapa:=.F.
	    	loop
		else
	    	lInsCapa:=.T.
		endif
    endif

AADD(aItens,aItem)

lMsErroAuto:= .f.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

          MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aDados, aItens, 3) 	

If lMsErroAuto         
	ROLLBACKSXE()
    //MOSTRAERRO() // tela de erro do msexecauto mostra campo com o erro

	aAutoErro := GETAUTOGRLOG()
    cErroCon:=XLOG(aAutoErro) 
	
    AADD(aErros,{alltrim(aDados[aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} )][2]),"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10))})    	
	
		AADD(aAuxaCols,Array(nUsado+1))
		
		for nk:=1 to nUsado+1
			aAuxaCols[len(aAuxaCols)][nK]:=aCols[j][nK]
		next
	
    lErro:=.T.
    DisarmTransaction()
Else
	AADD(aGravado,{alltrim(aDados[aScan( aDados, { |x| alltrim(x[1]) == "C5_NUM"} )][2]),"OK","Inserido"})
	ConfirmSx8()
EndIF             

aDados:={}
aItem:={}
aItens:={}

next


If lErro
	
	Situacao(aErros,aGravado)
	//aCols:={}
	//aCols:=aAuxaCols
	
Else
	msginfo("PROCESSADO COM SUCESSO!")
	oDlg:end()
EndIf

Return

/*
Funcao      : XLOG()  
Parametros  : aAutoErro
Retorno     : cRet
Objetivos   : Busca o erro gerado no msexecauto
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function XLOG(aAutoErro)
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; "
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet

/*
Funcao      : FIELDOKG6  
Parametros  : 
Retorno     : .T. or .F.
Objetivos   : Validar campos do aCols
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

User Function FIELDOKG6
Local cEstCli1:=""
Local nTpAliq1:=0
Local cAliqCod:=""
Local nC6Qtd:=0
Local nC6Prc:=0

if aHeader[oGetDados:oBrowse:ColPos][2]=="C5_CLIENTE"
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	if DbSeek(xFilial("SA1")+M->C5_CLIENTE+SA1->A1_LOJA)
		aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TPM_D1"})]:=substr(SA1->A1_NOME,1,30)
	endif
endif

if ALLTRIM(aHeader[oGetDados:oBrowse:ColPos][2])=="C5_CLIENT"
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	if DbSeek(xFilial("SA1")+M->C5_CLIENT+SA1->A1_LOJA)
		aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TPM_D2"})]:=substr(SA1->A1_NOME,1,30)
	endif
endif

if aHeader[oGetDados:oBrowse:ColPos][2]=="C6_PRODUTO"
	DbSelectArea("SB1") 
	DbSetOrder(1)
	if DbSeek(xFilial("SB1")+M->C6_PRODUTO)
		aCols[n][aScan( aHeader, { |x| alltrim(x[2]) == "C6_TPM_D2"} )] := SB1->B1_DESC						
	endif
endif

if ALLTRIM(aHeader[oGetDados:oBrowse:ColPos][2])=="C6_PRCVEN"
	nC6Prc:=M->C6_PRCVEN
	nC6Qtde:=aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})]
	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})]:=nC6Prc*nC6Qtde
endif

if ALLTRIM(aHeader[oGetDados:oBrowse:ColPos][2])=="C6_QTDVEN"
	nC6Prc:=aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})]
	nC6Qtde:=M->C6_QTDVEN
	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})]:=nC6Prc*nC6Qtde
endif


if ALLTRIM(aHeader[oGetDados:oBrowse:ColPos][2])=="C6_TES"
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	if DbSeek(xFilial("SA1")+aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CLIENTE"})]+aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C5_LOJACLI"})])

       	cEstCli1:=SA1->A1_EST
                	
       	if alltrim(cEstCli1)=="EX
       		nTpALiq1:=2
       	elseif alltrim(cEstCli1)<>alltrim(GETMV("MV_ESTADO"))
       		nTpALiq1:=1
       	endif
       	
		dbSelectArea("SF4")
		DbSetOrder(1)
		if DbSeek(xFilial("SF4")+SF4->F4_CODIGO)
			cAliqCod:=SF4->F4_CF
				       			
	    	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]:=alltrim(cvaltochar( val(substr(cAliqCod,1,1))+nTpALiq1 ))+substr(cAliqCod,2,4)
		
		endif        
	else    
		dbSelectArea("SF4")
		DbSetOrder(1)
		if DbSeek(xFilial("SF4")+aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})])
			cAliqCod:=SF4->F4_CF
				       			
	    	aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]:=alltrim(cAliqCod)
		
		endif        
    endif

endif  

Return(.T.)

/*
Funcao      : ValidaInfo  
Parametros  : aCols,aHeader
Retorno     : .T. or .F.
Objetivos   : Validar o botão Ok no MsGetDados
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function ValidaInfo(aCols,aHeader)
Local lRet:=.T.
Local nSeq:=0
Local cMsgErro:=""
             
for nSeq:=1 to len(aCols)

if !aCols[nSeq][len(aCols[nSeq])]
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})])
		if !"Número," $ cMsgErro
			cMsgErro+="Número,"
	    endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TIPO"})])
		if !"Tipo," $ cMsgErro
			cMsgErro+="Tipo,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CLIENTE"})])
		if !"Cliente," $ cMsgErro
			cMsgErro+="Cliente,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_LOJACLI"})])
		if !"Loja," $ cMsgErro
			cMsgErro+="Loja,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CONDPAG"})])
		if !"Condição Pagamento," $ cMsgErro
			cMsgErro+="Condição Pagamento,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})])
		if !"Produto," $ cMsgErro
			cMsgErro+="Produto,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_ITEM"})])
		if !"Item," $ cMsgErro
			cMsgErro+="Item,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})])
		if !"Preco," $ cMsgErro
			cMsgErro+="Preco,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})])
		if !"Quantidade," $ cMsgErro
			cMsgErro+="Quantidade,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})])
		if !"Valor," $ cMsgErro
			cMsgErro+="Valor,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})])
		if !"TES," $ cMsgErro
			cMsgErro+="TES,"
		endif
	endif
	if empty(aCols[nSeq][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})])
		if !"CF," $ cMsgErro
		cMsgErro+="CF,"
		endif
	endif

	oGetDados:oBrowse:SetBlkBackColor({|| GETDCLR(aCols,n,aHeader,.T.)})	
endif

next

if !empty(cMsgErro)
	Alert("Existe(m) campo(s) obrigatório(s) não preenchido(s): "+substr(cMsgErro,1,RAT(",",cMsgErro)-1))
	lRet:=.F.
endif

Return(lRet)    

/*
Funcao      : GETDCLR()  
Parametros  : aLinha,nLinha,aHeader,lCtrl
Retorno     : Nil
Objetivos   : Função para tratamento das regras de cores para a grid da MsNewGetDados
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function GETDCLR(aLinha,nLinha,aHeader,lCtrl)
Local nCor2 := RGB(192,192,192) //Cinza
Local nCor3 := 16777215 // Branco - RGB(255,255,255)
Local nCor4 := RGB(225,0,0)//RGB(255,083,083) //vermelho
Local nPosProd := aScan(aHeader,{|x| Alltrim(x[2]) == "C5_NUM"})
Local nUsado := Len(aHeader)+1
Local nRet := nCor3

	if lCtrl
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_TIPO"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CLIENTE"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_LOJACLI"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C5_CONDPAG"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif	
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_ITEM"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
		if empty(aCols[nLinha][aScan(aHeader,{|x|AllTrim(x[2])=="C6_CF"})]) .AND. !aLinha[nLinha][nUsado]
			nRet := nCor4
		endif
	endif

	If !Empty(aLinha[nLinha][nPosProd]) .AND. aLinha[nLinha][nUsado]
		nRet := nCor2
	ElseIf !Empty(aLinha[nLinha][nPosProd]) .AND. !aLinha[nLinha][nUsado] .AND. nRet<>nCor4
		nRet := nCor3
	Endif

Return nRet

/*
Funcao      : Situacao()  
Parametros  : aErros,aGravado
Retorno     : Nil
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function Situacao(aErros,aGravado)

Private _oDlg,oListBox
Private aListBox:={}

DEFINE MSDIALOG _oDlg TITLE "Pedidos" FROM C(178),C(180) TO C(665),C(966) PIXEL


	@ C(019),C(009) ListBox oListBox Fields HEADER "NUM PEDIDO", "SITUAÇÃO","DESCRIÇÃO" Size C(378),C(206) Of _oDlg Pixel
	@ C(230),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())
	
			For i:=1 to len(aErros)
				Aadd(aListBox,{aErros[i][1],aErros[i][2],aErros[i][3]})
			Next
            
			For i:=1 to len(aGravado)
				Aadd(aListBox,{aGravado[i][1],aGravado[i][2],aGravado[i][3]})
			Next
            
            oListBox:SetArray(aListBox)
	    
		
		oListBox:bLine := {|| {aListBox[oListBox:nAt,1],aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3]}}

   
ACTIVATE MSDIALOG _oDlg CENTERED 

Return

/*
Funcao      : C  
Parametros  : nTam
Retorno     : Nil
Objetivos   : Função para tratar resolução da tela
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)

/*
Funcao      : Render  
Parametros  : aCols
Retorno     : Nil
Objetivos   : Função que gera tela para inserir nova sequencia
Autor       : Matheus Massarotto
Data/Hora   : 12/03/2012
*/

Static Function Render(aCols)
// Variaveis Locais da Funcao
Local cEdit1	 := Space(6)
Local oEdit1
Local _oDlg1

DEFINE MSDIALOG _oDlg1 TITLE "Sequencia" FROM C(259),C(344) TO C(420),C(610) PIXEL

	// Cria as Groups do Sistema
	@ C(008),C(015) TO C(063),C(119) LABEL "Número pedido" PIXEL OF _oDlg1

	// Cria Componentes Padroes do Sistema
	@ C(026),C(037) MsGet oEdit1 Var cEdit1 Size C(060),C(009) Picture "@X" COLOR CLR_BLACK PIXEL OF _oDlg1
	@ C(043),C(051) Button "Gerar" action(processa({||PrecRender(@aCols,cEdit1),_oDlg1:end()})) Size C(037),C(012) PIXEL OF _oDlg1

ACTIVATE MSDIALOG _oDlg1 CENTERED 

Return

/*
Funcao      : PrecRender  
Parametros  : aCols,cNum
Retorno     : Nil
Objetivos   : Função auxiliar a Render, para processar a sequencia informada na tela
Autor       : Matheus Massarotto
Data/Hora   : 12/03/2012
*/

Static Function PrecRender(aCols,cNum)
Local u:=1

if MSGYESNO("Deseja realmente alterar o número do pedido?")
	if !empty(cNum)
		for u:=1 to len(aCols) 
			ProcessMessages()
			aCols[u][aScan(aHeader,{|x|AllTrim(x[2])=="C5_NUM"})]:=cNum
		next
	endif
endif

Return

/*
Funcao      : MRoundInt
Parametros  : x,nBase  (x: informe o valor a converter) (nbase: a base que será utilizada para conversão) 
Retorno     : nRet
Objetivos   : Função para converter um valor inteiro para uma quantidade minima permitida, arredondando para mais. Exemplor: x=25, nbase=10 , retorna 30
Autor       : Matheus Massarotto
Data/Hora   : 09/03/2012
*/

Static Function MRoundInt(x,nbase)
Local nResult:=0
Local nRet:=0
Local nQtdFal:=0

//Pegando a parte decimal do valor
nResult:=x/nbase - int(x/nbase)

//Pegando a quantidade faltante para completar a qtde minima
nQtdFal:=nbase-(nResult*nbase)

nRet:=nQtdFal+x

Return(nRet)