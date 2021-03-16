#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

#define ENTER CHR(13)+CHR(10)

*=====================================================================================================================================*
/*/{Protheus.doc} GTFIN039
//TODO Fonte para tratamento de fun��es com retorno logico no processo de CNAB via ACCESSTAEG:

nOPCAO := 1 "U_ALTEMP()- VERIFICA SE O NOME DA EMPRESA J� TEVE ALTERA��O NA TELA DE PARAMETROS. (CHAMADO NO CAMPO)" 
nOPCAO := 2 "U_VlCodBar(cCodBar) - FUN��O QUE VALIDA SE O C�DIGO DE BARRAS OU A LINHA DIGITAVEL SE EST�O SENDO DIGITADOS CORRETAMENTE (CAMPOS E2_LINDIG E E2_CODBAR)" 
nOPCAO := 3 "U_CPFILPOS() - FUN��O PARA VERIFICAR SE OS CAMPOS CUSTOMIZADOS EXISTEM, UTILIZADO NAS FUN��ES QUE UTILIZAM ESSES CAMPOS"
nOPCAO := 4 "U_EMAILREJ() - fun��o para receber os dados do t�tulo que foi rejeitado e enviar por email para o respons�vel da empresa/cliente.
nOPCAO := 5 "U_ARQCNAB() - fun��o para exibir uma lista de arquivos CNAB que se encontram na pasta de retorno 
    - nOPCAO := 6 "U_SELECARQ() - fun��o para validar se arquivo foi selecionado para processar retorno.
    - nOPCAO := 7 "U_DETALARQ() - fun��o para abrir o relat�rio retorno CNAB e exibir os detalhes dos titulos se foram rejeitados ou incluidos  
@author Leosanlim
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
USER FUNCTION GTFIN039(nOPCAO,cDados)
LOCAL lRet
//*********************************************
//INICIO VARIAVEIS DA FUN��O U_ALTEMP()
LOCAL lRegistro
//FIM VARIAVEIS DA FUN��O U_ALTEMP()
//*********************************************\\
//INICIO VARIAVEIS DA FUN��O U_VlCodBar(cCodBar)
Local nX
Local cCampo
LOCAL cCodBar 
//FIM VARIAVEIS DA FUN��O U_VlCodBar(cCodBar)
//INICIO VARIAVEIS DA FUN��O U_CPFILPOS()
Local cMsgCpos := ""//"Um ou mais campos obrigat�rios n�o foram preenchidos:" + ENTER
Local aCpos_Z0F
Local aCpos_Z0D
Local aCpos_SEE
Local aCpos_SA1
Local aCpos_SA2 
Local aCpos_SE1
Local aCpos_SE2
Local aCpos_SEA
Local aAreaSEE , aAreaSA1,aAreaSA2
Local aAreaSE1, aAreaSE2, aAreaSEA
//FIM VARIAVEIS DA FUN��O U_CPFILPOS()

//INICIO VARIAVEIS DA FUN��O U_EMAILREJ()
LOCAL aSE2REJ    
LOCAL cEmail := ""
LOCAL cValTit := ""
//FIM VARIAVEIS DA FUN��O U_EMAILREJ()

//INICIO VARIAVEIS nOPCAO == 5 FUNCAO U_ARQCNAB
LOCAL oDlg, oBrowse, oColumn, aCols :={}, cQuery := "",aFiles := {}
LOCAL aButtons, bCancel, bOk, bImagem, bLinClick, bHeadClick
LOCAL aScreens
LOCAL uAux
LOCAL aHeader
LOCAL cPergunt, cBanco, cAgencia, cConta, cSubCta
    //VARIAVEIS nOPCAO == 6 FUNCAO U_SELECARQ
    LOCAL cMsgMarc
    //VARIAVEIS nOPCAO == 7 FUNCAO U_DETALARQ
    LOCAL nLin, aPergF430, cArqCFG, cArqCFG

//FIM VARIAVEIS nOPCAO == 6 FUNCAO U_SELECARQ, nOPCAO == 7 FUNCAO U_DETALARQ e nOPCAO ==5 FUNCAO U_ARQCNAB


/*************************
INICIO DAS OP��ES 
*************************/
DO CASE
    CASE nOPCAO == 1 //U_ALTEMP()
        DbSelectArea("Z0D")
        Z0D->(DbSetOrder(1))
        lRegistro := Z0D->(dbSeek(xFilial("Z0D")+SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA+SEE->EE_SUBCTA))

        IF lRegistro .AND. Z0D->Z0D_ALTERA == "1"
            MSGINFO("CASO PRECISE ALTERAR NOVAMENTE, INFORME O ADMINISTRADOR","NOME DA EMPRESA JA TEVE UMA ALTERA��O!")
            lRet := .F.
        ELSEIF !EMPTY(ALLTRIM(LEFT(M->EE_P_NOEMP,30)))
            M->EE_P_NOEMP := STRTRAN(ALLTRIM(LEFT(M->EE_P_NOEMP,30))," ","_")
            lRet := .T.
        ENDIF

        Z0D->(dbCloseArea())

    CASE nOPCAO == 2 //U_VlCodBar(cCodBar)
        lRet := .T.

        cCodBar := Alltrim(cDados)
        // Completa o tamanho do codigo de barras se ele for menor que 44 por se tratar de uma
        // linha digitavel.
        If Len(cCodBar) < 44
            cCodBar := Left(cCodBar+Replicate("0", 48-Len(cCodBar)),47)
        Endif

        If  Len(cCodBar) > 47 .and. AllTrim(SubStr(cCodBar,48)) == ""
            cCodBar := SubStr(cCodBar,1,47)
        EndIf

        Do Case
        Case Len(cCodBar)==44 // Validacao do codigo de Barras
            // Se nao conseguir validar o DV do codigo de barras, tenta validar como
            // se fosse titulo de concessionaria.	
            If Dv_BarCode(Left(cCodBar,4)+SubStr(cCodBar,6))!=SubStr(cCodBar,5,1)
                // Codigo de barras de concessionarias 
                cCampo:=Left(cCodBar,3)+SubStr(cCodBar,5)
                If VldMod(cCampo,cCodBar)!=SubStr(cCodBar,4,1)
                    Help(" ",1,"INVCDBAR",,'Codigo de Barras Inv�lido.',1,0) //'Codigo de Barras Inv�lido.'
                    lRet := .F. // Invalido
                Endif	
            Endif
        Case Len(cCodBar)==47 // Validacao da linha digitavel
            // Elimina os digitos
            cCodSemDv	:= Left(cCodBar,9)+SubStr(cCodBar,11,10)+SubStr(cCodBar,22,10)
            cCodBar2		:= Left(cCodBar,4)+Substr(cCodBar,34)+Substr(cCodSemDv,5)
            // Calcula os digitos e os compara com os digitos informados
            For nX := 1 To 3
                cCampo := SubStr(cCodSemDv,If(nX==1,1,If(nX==2,10,20)),If(nX==1,9,10))
                If Mod10(cCampo) != SubStr(cCodBar,If(nX==1,10,If(nX==2,21,32)),1)
                    Help(" ",1,"INVCDBAR",,'Linha Digit�vel Inv�lida.',1,0) //'Linha Digit�vel Inv�lida.'
                    lRet := .F.
                    Exit
                Endif
            Next
            //Valido o digito verificador geral da linha digitada (pos. 33 da linha digitada)
            If lRet
                If Dv_BarCode(cCodBar2)!=SubStr(cCodBar,33,1)			
                    Help(" ",1,"INVCDBAR",,'Linha Digit�vel Inv�lida.',1,0) //'Linha Digit�vel Inv�lida.'
                    lRet := .F.
                Endif
            Endif
        OtherWise // Validacao da linha digitavel de concessionarias
            // Elimina os digitos
            cCodSemDv := Left(cCodBar,11)+SubStr(cCodBar,13,11)+SubStr(cCodBar,25,11)+SubStr(cCodBar,37,11)
            // Calcula os digitos e os compara com os digitos informados
            For nX := 1 To Len(cCodSemDv) Step 11
                cCampo := SubStr(cCodSemDv,nX,11)
                nPos :=  If(nX==1,12,If(nX==12,24,If(nX==23,36,48)))
                If VldMod(cCampo,cCodBar) != SubStr(cCodBar,nPos,1)
                    Help(" ",1,"INVCDBAR",,'Codigo de Barras Inv�lido.',1,0) //'Codigo de Barras Inv�lido.'
                    lRet := .F.
                        Exit
                Endif
            Next
        EndCase

    CASE nOPCAO == 3 //U_CPFILPOS()
        lRet := .T.
        aCpos_Z0F := {{"Z0F_FILIAL"},{"Z0F_IDCNAB"},{"Z0F_BANCO"},{"Z0F_AGE"},{"Z0F_CTA"},{"Z0F_PREFIX"},{"Z0F_NUM"},{"Z0F_PARCEL"};
            ,{"Z0F_TIPO"},{"Z0F_FORCLI"},{"Z0F_NOMFC"},{"Z0F_CGCCPF"},{"Z0F_DTVENC"},{"Z0F_DTBAIX"},{"Z0F_DTPROC"},{"Z0F_HRPROC"};
            ,{"Z0F_VALOR"},{"Z0F_OCORRE"},{"Z0F_DESCOC"}}
            
        aCpos_Z0D := {{"Z0D_FILIAL"},{"Z0D_BANCO"},{"Z0D_AGE"},{"Z0D_CTA"},{"Z0D_SUBCTA"};
            ,{"Z0D_DIR"},{"Z0D_OPERA"},{"Z0D_STATUS"},{"Z0D_M_MSG"},{"Z0D_DTCRI"},{"Z0D_HRCRI"},{"Z0D_USCRI"},{"Z0D_ALTERA"}}
            
        aCpos_SEE := {{"EE_P_ACCES"},{"EE_P_NOEMP"},{"EE_P_ACEIT"},{"EE_P_TPIMP"},{"EE_P_PROTE"},{"EE_P_PERMT"},{"EE_P_TIPO"},{"EE_P_PERJR"},{"EE_P_EMAIL"}}
        aCpos_SA1 := {{"A1_P_PROTE"},{"A1_P_DIASP"},{"A1_P_PERMT"},{"A1_P_TIPO"},{"A1_P_PERJR"},{"A1_P_CL_PA"},{"A1_P_AGECL"},{"A1_P_CTACL"}}
        aCpos_SA2 := {{"A2_DVAGE"},{"A2_DVCTA"}}
        aCpos_SE1 := {{"E1_P_TPMUL"},{"E1_P_MULTA"},{"E1_P_JUROS"}}
        aCpos_SE2 := {{"E2_P_MULTA"},{"E2_P_JUROS"},{"E2_P_TRIB"},{"E2_P_CODRE"},{"E2_P_TPCON"},{"E2_P_CGCON"},{"E2_P_NMCON"},{"E2_P_COMPE"};
            ,{"E2_P_VRENT"},{"E2_P_VLINS"},{"E2_P_REFE"},{"E2_P_REBRU"},{"E2_P_PERRB"},{"E2_P_INSCR"},{"E2_P_DIVAT"},{"E2_P_PARCE"};
            ,{"E2_P_RENAV"},{"E2_P_UFIPV"},{"E2_P_CDMUN"},{"E2_P_PLACA"},{"E2_P_OPPAG"},{"E2_P_OPRET"},{"E2_P_DCORI"},{"E2_P_VLMON"};
            ,{"E2_P_IDFGT"},{"E2_P_LCSOC"},{"E2_P_DGSOC"},{"E2_LINDIG"},{"E2_FORBCO"},{"E2_FORAGE"},{"E2_FORCTA"},{"E2_FAGEDV"};
            ,{"E2_FCTADV"},{"E2_P_NOMBN"},{"E2_P_CGCBN"},{"E2_P_TIPO"},{"E2_P_TPMV"},{"E2_P_INSMV"},{"E2_P_TPMOE"}}
        aCpos_SEA := {{"EA_P_IDCNA"}}
        aAreaSEE := GetArea("SEE")
        aAreaSA1 := GetArea("SA1")
        aAreaSA2 := GetArea("SA2")
        aAreaSE1 := GetArea("SE1")
        aAreaSE2 := GetArea("SE2")
        aAreaSEA := GetArea("SEA")

        DbSelectArea("SEE") 
        FOR x:=1 TO LEN(aCpos_SEE)
            IF FieldPos(aCpos_SEE[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SEE[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SA1") 
        FOR x:=1 TO LEN(aCpos_SA1)
            IF FieldPos(aCpos_SA1[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SA1[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SA2") 
        FOR x:=1 TO LEN(aCpos_SA2)
            IF FieldPos(aCpos_SA2[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SA2[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SE1") 
        FOR x:=1 TO LEN(aCpos_SE1)
            IF FieldPos(aCpos_SE1[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SE1[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SE2") 
        FOR x:=1 TO LEN(aCpos_SE2)
            IF FieldPos(aCpos_SE2[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SE2[x,1] + ENTER
            ENDIF
        NEXT

        DbSelectArea("SEA") 
        FOR x:=1 TO LEN(aCpos_SEA)
            IF FieldPos(aCpos_SEA[x,1]) == 0
                lRet := .F.
                cMsgCpos += aCpos_SEA[x,1] + ENTER
            ENDIF
        NEXT


        IF !lRet
        cMsgCpos := "Um ou mais campos obrigat�rios n�o foram preenchidos:" + ENTER + cMsgCpos
            Help("",1,"CAMPOS OBRIGAT�RIOS",,cMsgCpos, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com o Suporte e informe a mensagem!"})
        ENDIF

        RestArea(aAreaSEE)   // Retorna o ambiente anterior
        RestArea(aAreaSA1)   // Retorna o ambiente anterior
        RestArea(aAreaSA2)   // Retorna o ambiente anterior
        RestArea(aAreaSE1)   // Retorna o ambiente anterior
        RestArea(aAreaSE2)   // Retorna o ambiente anterior
        RestArea(aAreaSEA)   // Retorna o ambiente anterior

    CASE nOPCAO == 4 //U_EMAILREJ()
    
        /*�������������������������������������������������������������������������Ĵ��
        ���Parametros�Parametros do array aSE2REJ:                                ���
        ���          �1. Z0F_PREFIX - Prefixo do titulo                           ���
        ���          �2. Z0F_NUM      Numero do Titulo                            ���
        ���          �3. Z0F_PARCEL   Parcela Titulo                              ���
        ���          �4. Z0F_TIPO     Tipo do titulo                              ���
        ���          �5. Z0F_FORCLI   Cod Fornecedor                              ���
        ���          �6. Z0F_NOMFC    Nome do Fornecedor                          ���
        ���          �7. Z0F_DTEMIS   Data de emiss�o                             ���
        ���          �8. Z0F_DTVENC   Data Vencimento Real                        ���
        ���          �9. Z0F_VALOR    Valor do titulo                             ���
        ���          �10. Z0F_BANCO   Codigo do banco                             ���
        ���          �11. Z0F_DESCOC  Descricao ocorrencia                        ���
        ���          �12. Z0F_NUMBOR  Numero do Bordero                           ���
        ���          �13. Z0F_IDCNAB  Idcnab                                      ���
        ���          �14. Z0F_REFBAN  COD Ocorrencia                              ���
        �������������������������������������������������������������������������Ĵ��*/
    
        aSE2REJ := cDados
        

        cEmail := ' <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head>'
        cEmail += '<meta name="viewport" content="text/html; width=device-width" initial-scale="1.0" user-scalable="yes">'
        cEmail += '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
        cEmail += '<title>Titulo Rejeitado</title>'
        cEmail += '<style>'
        cEmail += '@font-face {font-family: myFirstFont;src: url(sansation_light.woff);}'
        cEmail += 'body, center {font-family: Tahoma, Verdana, sans-serif; width: 100%;}'
        cEmail += 'body {text-align: center; width: 100% !important;}'
        cEmail += 'table {background-color: #fff;}'
        cEmail += 'td {font-family: Arial, sans-serif;}'
        cEmail += '/* bugfix iOS: remove o background da imagem depois que carregou, pra evitar bugs de renderizacao */'
        cEmail += 'img[src^="http"] {background: transparent;max-width: 540px !important;}'
        cEmail += '.clgradi {'
        cEmail += '/* Permalink - use to edit and share this gradient: http://colorzilla.com/gradient-editor/#e5e5e5+0,ffffff+100 */'
        cEmail += 'background: #e5e5e5; /* Old browsers */'
        cEmail += 'background: -moz-linear-gradient(top, #e5e5e5 0%, #ffffff 100%); /* FF3.6-15 */'
        cEmail += 'background: -webkit-linear-gradient(top, #e5e5e5 0%,#ffffff 100%); /* Chrome10-25,Safari5.1-6 */'
        cEmail += 'background: linear-gradient(to bottom, #e5e5e5 0%,#ffffff 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */'
        cEmail += 'filter: progid:DXImageTransform.Microsoft.gradient( startColorstr="#e5e5e5", endColorstr="#ffffff",GradientType=0 ); /* IE6-9 */'
        cEmail += '}</style>'
        cEmail += '</head>'
        cEmail += '<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" style="-ms-text-size-adjust: 100%; font-size: 14px; -webkit-text-size-adjust: 100%;  font-family: Tahoma, Verdana, sans-serif; text-align: center; -webkit-font-smoothing: antialiased; width: 100% !important;">'
        cEmail += '<center style="-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%;  font-family: Tahoma, Verdana, sans-serif; font-size: 14px; width: 100%;">'
        cEmail += '<div id="principal" style="max-width: 600px; -webkit-text-size-adjust: none; text-align: left; width: 94%;" align="left">'
        cEmail += '<table cellpadding="0" cellspacing="0" border="0" bgcolor="#ffffff" width="500px">'
        cEmail += '<tr id="logo" height="150"><td valign="middle" align="left" >'
        cEmail += '<table cellpadding="0" cellspacing="0" border="0" bgcolor="#ffffff" width="100%" height="150">'
        cEmail += '<tr><td align="center" valign="middle"><img src="https://www.hlb.com.br/wp-content/uploads/sites/37/2019/05/hlb-brasil-site-1.png"></td><td align="center" valign="middle">&nbsp;</td></tr>'
        cEmail += '</table></td></tr>'
        cEmail += '<tr><td bgcolor="#4f2682">&nbsp;</td></tr>'
        cEmail += '<tr><td><table cellpadding="0" cellspacing="0" border="0" bgcolor="#ffffff" width="100%" align="center">'
        cEmail += '<tr><td align="center" height="40">&nbsp;</td></tr>'
        cEmail += '<tr><td align="center" valign="middle" >'
        cEmail += '<span style="font-size:28px; font-weight:bold;"> Titulos Rejeitados  </span><br>'
        cEmail += '</td></tr>'
        cEmail += '<tr><td align="center" height="40">&nbsp;</td></tr>'
        cEmail += '<tr><td align="center" height="40">'
        cEmail += '<span style="font-size:18px;">Os titulos abaixo foram rejeitados pelo banco e foram liberados no sistema para manuten��o!  </span><br><br>'
        
        cEmail += '<table border="1" width="1200"  style="padding: 0"><tr>'
        cEmail += '<td width="200"><font face="Courier New" size="2"><b>Fornecedor</b></font></td>'
        cEmail += '<td width="50"><font face="Courier New" size="2"><b>Titulo</b></font></td>'     
        cEmail += '<td width="50"><font face="Courier New" size="2"><b>Bordero</b></font></td>'
        cEmail += '<td width="150"><font face="Courier New" size="2"><b>Valor</b></font></td>'  
        cEmail += '<td width="80"><font face="Courier New" size="2"><b>Data Emissao</b></font></td>'
        cEmail += '<td width="80"><font face="Courier New" size="2"><b>Data Vencimento</b></font></td>'
        cEmail += '<td width="300"><font face="Courier New" size="2"><b>Motivo</b></font></td>'
        For i:=1 to Len(aSE2REJ)
            cValTit := TRANSFORM(aSE2REJ[i,9], "@E 999,999,999.99")  
            cEmail += '	<tr>'   
            cEmail += '		<td width="200"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,5])+'-'+cValToChar(aSE2REJ[i,6])+'</font></td>' 
            cEmail += '		<td width="50"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,2])+' '+cValToChar(aSE2REJ[i,3])+'</font></td>'       
            cEmail += '		<td width="50"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,12])+'</font></td>'    
            cEmail += '		<td width="150"><font face="Courier New" size="2">R$ '+cValTit+'</font></td>' 
            cEmail += '		<td width="80"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,7])+'</font></td>'
            cEmail += '		<td width="80"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,8])+'</font></td>'
            cEmail += '		<td width="300"><font face="Courier New" size="2">'+cValToChar(aSE2REJ[i,11])+'</font></td>'
            cEmail += '	</tr>'    
        Next     
        cEmail += '</table>'
        cEmail += '</td></tr>'
        cEmail += '<tr><td height="18" bgcolor="#ffffff"></td></tr>'
        cEmail += '</table></td></tr>'
        cEmail += '</table></div></center></body></html>'
               
               
        oEmail           :=  DEmail():New()
        oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
        oEmail:cTo		:=  AllTrim(SUPERGETMV("MV_P_00131",.F.,"log.finnet@hlb.com.br"))   // Ex: "tiago.mendonca@pryor.com.br" //CAS - 01/07/2020 altera��o para o novo e-mail log.finnet@hlb.com.br                  
        oEmail:cSubject	:=	"Titulo Rejeitado na empresa (" +ALLTRIM(SM0->M0_NOME)+") 
      	
        oEmail:cBody   	:= 	cEmail
        //oEmail:cAnexos   :=  cFile
        lRet := oEmail:Envia()
        //cText:="Gera��o de Pedido"     
        //MsgInfo("Pedido "+Alltrim(cNum)+" gerado com sucesso, enviado e-mail para o almoxerifado.","EUROsilicone")     
        //FErase(cFile) 	
    CASE nOPCAO == 5 //U_ARQCNAB()
		bCancel   := {|| lRet:=.T. .AND. oDlg:End()}
        bOk       := {|| Processa({|| IF(U_GTFIN039(6,@aCols),lRet:=.T. .AND. oDlg:End(), lRet:=.F.) }, "Confirma arquivo")}  
		aButtons  := {{"Detalhes" ,{|| Processa({||U_GTFIN039(7,aDtArq:={@aCols,oBrowse:nAt})},"Carregando Detalhes CNAB")},"Destalhes Cnab"}}
		aScreens  := getScreenRes()
		bImagem := {|| if(aCols[oBrowse:nAt,1], "LBOK", "LBNO")}
		bLinClick := {|| if(aCols[oBrowse:nAt,1], aCols[oBrowse:nAt,1]:=.F., aCols[oBrowse:nAt,1]:=.T.)}//bLinClick := {|| MarcaIt(@oBrowse,@aCols)}
		bHeadClick := {|| oBrowse:Refresh()}
		aHeader := {{"Status", "Status", "@BMP", 01,0,.T.,,"C",,},;
		{"Diretorio Cnab", "Diretorio", "", 99, 0, .T., , "C",,},;
		{"Arquivo Cnab", "Arquivo", "", 35, 0, .T., , "C",,},;
		{"Data Criacao", "Data", "@!", 10, 0, .T., , "C"},;
		{"Hora Criacao", "Hora", "@!", 10, 0, .T., , "C"}}  
		cPergunt := cDados
		cBanco   := IF(cPergunt == "AFI200",MV_PAR06,MV_PAR05)
		cAgencia := IF(cPergunt == "AFI200",MV_PAR07,MV_PAR06)//IF(cPergunt == "AFI420",MV_PAR06,mv_agencia)
		cConta   := IF(cPergunt == "AFI200",MV_PAR08,MV_PAR07)//IF(cPergunt == "AFI420",MV_PAR07,mv_cta)
		cSubCta  := IF(cPergunt == "AFI200",MV_PAR09,MV_PAR08)//IF(cPergunt == "AFI420",MV_PAR08,mv_subcta)

		IF !EMPTY(cSubCta) .AND. !EMPTY(cConta)
			DbSelectArea("SEE")
			SEE->(DbSetOrder(1))
			IF SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta))				
				IF SEE->EE_RETAUT $ '2|3'
					//aFiles := Directory(Alltrim(SEE->EE_DIRPAG)+"*.TXT")														//CAS 16-07-2019 Linha Antiga (BACKUP)
					//aFiles := Directory(IF(cPergunt == "AFI200",Alltrim(SEE->EE_DIRREC),Alltrim(SEE->EE_DIRPAG))+"*.TXT")		//CAS 16-07-2019 Ajuste para verificar se vai pegar do Diretorio "A PAGAR" ou "A RECEBER"
					If cPergunt == "AFI200"
					  	aFiles := Directory( Alltrim(SEE->EE_DIRREC)+SM0->M0_CODIGO+"_rr_*.TXT")
					Else
                        If ISINCALLSTACK("U_UFINA473")		//CAS - 18/01/2021 Ajuste para Extrato - Concilia��o Autom�tica
                            aFiles := Directory( Alltrim(SEE->EE_DIRPAG)+"EXT_"+SM0->M0_CODIGO+"_*.TXT")
                        Else
						    aFiles := Directory( Alltrim(SEE->EE_DIRPAG)+SM0->M0_CODIGO+"_pr_*.TXT")
                        EndIF
					EndIF
					For i := 1 to len(aFiles)
						//aadd(aCols,{.F.,Alltrim(SEE->EE_DIRPAG),aFiles[i,1],DTOS(aFiles[i,3]),aFiles[i,4]})					//CAS 16-07-2019 Linha Antiga (BACKUP)
						  aadd(aCols,{.F.,IF(cPergunt == "AFI200",Alltrim(SEE->EE_DIRREC),Alltrim(SEE->EE_DIRPAG)),aFiles[i,1],DTOS(aFiles[i,3]),aFiles[i,4]})	//CAS 16-07-2019 Ajuste para verificar se vai pegar do Diretorio "A PAGAR" ou "A RECEBER"
					Next
				ENDIF
			ENDIF
			SEE->(dbCloseArea())
		ENDIF

		if len(aCols)=0
			aCols:={{.f.,"","","",""}}
		endif
		//Tela de Selecao de Notas
		oDlg = TDialog():New()
		oDlg:nLeft     := 0
		oDlg:nTop	   := 0
		oDlg:nHeight   := aScreens[2]-(aScreens[2]*0.3)  //600
		oDlg:nWidth	   := aScreens[1]-(aScreens[1]*0.2) //900
		oDlg:lCentered := .T.
		oDlg:lEscClose := .T.
		oDlg:cCaption  := "Interface de Cnabs"
		oDlg:bInit     := {|| EnchoiceBar(oDlg,bOk/*bCancel*/,bCancel,,aButtons,,,.F.,.F.,.F.,.T.,.F.)}


		oBrowse := FWBrowse():New(oDlg)
		oBrowse:DisableReport()
		oBrowse:DisableSaveConfig()
		oBrowse:SetDescription('Retorno CNAB')
		oBrowse:SetDataArray() //define que ser� com array
		oBrowse:SetArray(aCols)

		//-------------------------------------------------------------------//
		// Adiciona as colunas do Browse                                     //
		//-------------------------------------------------------------------//
		//Cria uma coluna de marca/desmarca
		oBrowse:AddMarkColumns( bImagem , bLinClick ,bHeadClick )

		//Cria uma coluna de status
		//oBrowse:AddStatusColumns( bStatus,bShow )

		for i := 3 To len(aHeader)
			oColumn := FWBrwColumn():New()
			oColumn:SetData( &("{|| aCols[oBrowse:At()," + cValToChar(i) + "]}") ) //Dados aCols[oBrowse:At()," + cValToChar(i]
			oColumn:SetTitle( aHeader[i,1]) //Titulo
			oColumn:SetType( aHeader[i,8])  // Tipo
			oColumn:SetSize( aHeader[i,4] )
			oColumn:SetDecimal( aHeader[i,5] )
			oColumn:SetPicture( aHeader[i,3] )
			//oColumn:blDblClick := &(  '{|| Aviso( "Inteface MIRO - '+aHeader[i,1]+'",aCols[oBrowse:nAt,' + cValToChar(i+1) +'], {"OK"}, 3 )}'   )
			oBrowse:SetColumns({oColumn}) //Adiciona a Coluna ao Browse
		next

		oBrowse:Activate() //Ativa��o do Browse

		oDlg:Activate() //Ativa��o da janela 
        

    CASE nOPCAO == 6 //U_SELECARQ() 
        aCols := cDados 
        lRet := .F.
        cMsgMarc := ""
        for nCnt:=1 to len(aCols)
			IF aCols[nCnt, 1]
				/*cMsgMarc := ""
                cMsgMarc +="<center><h1><font color='#ff0000'>Aten��o!</font></h1></center><br>"
                cMsgMarc +="Ao confirmar a sele��o desse arquivo, a rotia de retorno ira realizar a baixa dos titulos confirmados,<br>"
                cMsgMarc +="ou a libera��o dos titulos rejeitados.<br><br>"
                cMsgMarc +="<b>Arquivo: ( "+AllTrim(aCols[nCnt,3])+" ) <b><br><br>"
                cMsgMarc +=" <b>Voc� confirma a sele��o desse arquivo?</b>"
                IF MSGYESNO(cMsgMarc)
                */
                IF ISINCALLSTACK("FINA740")
                    MV_PAR04 := AllTrim(aCols[nCnt,2])+AllTrim(aCols[nCnt,3])
                Else
                	MV_PAR03 := AllTrim(aCols[nCnt,2])+AllTrim(aCols[nCnt,3])                
                EndIF
                //MSGINFO("Existe arquivo selecionado "+AllTrim(aCols[nCnt,2])+AllTrim(aCols[nCnt,3]))
                lRet := .T.
                //ENDIF
            ELSE         
                cMsgMarc := "Nenhum arquivo CNAB foi selecionado!"
            ENDIF
		next
		 
		IF !lRet
			MSGINFO(cMsgMarc) 
		ENDIF

    CASE nOPCAO == 7 //U_DETALARQ()
        aCols := cDados[1]
        nLin := cDados[2] 
        aPergF430 := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,MV_PAR12}
        cArqCFG := IF(ISINCALLSTACK("FINA740"),MV_PAR05,MV_PAR04)     	// Carteira ?  1=Receber;2=Pagar		//CAS 		//cArqCFG := MV_PAR04         
        cCamFile := AllTrim(aCols[nLin,2])+AllTrim(aCols[nLin,3]) 												//CAS 16-07-2019 Vari�vel para guardar o Diret�rio e Arquivo do CNAB             
        
        // atualiza o pergunte do FINR650
		aVet650 := {{mv_par01	, AllTrim(aCols[nLin,2])+AllTrim(aCols[nLin,3])	},; // 01 Arquivo de Entrada ?          	 
                    {mv_par02	, aPergF430[4]	},; // 02 Arquivo de Config ?           	
                    {mv_par03	, aPergF430[5]	},; // 03 Codigo do Banco ?             
                    {mv_par04	, aPergF430[6]	},; // 04 Codigo da Agencia ?           
                    {mv_par05	, aPergF430[7]	},; // 05 Codigo da Conta ?             
                    {mv_par06	, aPergF430[8]	},; // 06 Codigo da SubConta ?          
                    {mv_par07	, IF(cPergunt == "AFI200","1","2") },; // 07 Carteira ?  1=Receber;2=Pagar		//CAS 16-07-2019 Ajuste para verificar se o Relat�rio vai pegar do Contas "A PAGAR" ou "A RECEBER"
                    {mv_par08	, CValToChar(aPergF430[10])	}}  // 08 Configuracao CNAB ?           

		// atualiza as perguntas do FINR650 conforme os dados do arquivo de bancos
		SX1->( dbSetORder(1))
		For nB := 1 to Len(aVet650)
			If SX1->( DbSeek(PadR("FIN650", Len(SX1->X1_GRUPO)) +Strzero(nB,2)))
				Reclock("SX1",.F.)
				ConOut("## EZ4 - FINR650: "+CVALTOCHAR(nB)+" = "+CVALTOCHAR(aVet650[nB,2]))
					SX1->X1_CNT01 := SUBSTR(aVet650[nB,2],1,60)//aVet650[1,2]
					SX1->X1_CNT02 := SUBSTR(aVet650[nB,2],61)

				if SX1->X1_GSC == "C"
					SX1->X1_PRESEL := Val(aVet650[nB,2])
				Endif	

				SX1->( MsUnlock() )
		    EndIf
		Next
        //CHAMA A FUN��O DE RELAT�RIO CNAB  
         
 		//CAS 16-07-2019 Trecho para alterar o X1_CNT01 e MV_PAR do Pergunte FIN650
       	SX1->( DbSeek(PadR("FIN650", Len(SX1->X1_GRUPO))))
		aPergAux:= {}
		Pergunte(PadR("FIN650", Len(SX1->X1_GRUPO)), .F.,, , , , @aPergAux)
		aPergAux[1,8] := MV_PAR01 := cCamFile
		aPergAux[2,8] := MV_PAR02 := cArqCFG
		MV_PAR07 := IF(ISINCALLSTACK("FINA740"),1,2) 				// 07 Carteira ?  1=Receber;2=Pagar
		__SaveParam("FIN650", aPergAux)   
		//-------------------------------------------------------------------------
       
        FINR650()
        //ABRE O PERGUNTE AFI430 PARA VOLTAR AO PADR�O 
        //Pergunte(Padr("AFI430",Len(SX1->X1_GRUPO)),    .F., Nil,    Nil,     Nil, .F.)  //CAS - 24/06/2020 Como estava antes
        //CAS - 22/12/2020 - Adicionaro o IF do (ISINCALLSTACK("FINA740")) para AFI200 ou AFI430
        IF(ISINCALLSTACK("FINA740"))
            Pergunte(Padr("AFI200",Len(SX1->X1_GRUPO)),    .F., Nil,    Nil,     Nil, Nil)  //CAS - 24/06/2020 Ajustado o ultimo parametro com NIL para manter os dados do SX1 do FIN650
        Else
            Pergunte(Padr("AFI430",Len(SX1->X1_GRUPO)),    .F., Nil,    Nil,     Nil, Nil)  //CAS - 24/06/2020 Ajustado o ultimo parametro com NIL para manter os dados do SX1 do FIN650
        EndIF

ENDCASE
RETURN lRet
*=====================================================================================================================================*

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Dv_BarCode�Autor  �Claudio D. de Souza � Data �  14/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de um codigo de barras padrao  ���
���          �Febraban.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DV_BarCode( cBarCode )
	*=====================================================================================================================================*
Local cDig
Local nPos
Local nAux := 0

For nPos := 1 To 43
	nAux += Val(SubStr(cBarCode,nPos,1)) * If( nPos<= 3, ( 5-nPos),     ;
		If( nPos<=11, (13-nPos),     ;
		If( nPos<=19, (21-nPos),     ;
		If( nPos<=27, (29-nPos),     ;
		If( nPos<=35, (37-nPos),     ;
		(45-nPos) )))))
Next
nAux := nAux % 11
cDig := If( (11-nAux)>9, 1, (11-nAux) )

Return Str(cDig,1)
*=====================================================================================================================================*

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Mod10     �Autor  �Claudio D. de Souza � Data �  14/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de uma sequencia de numeros    ���
���          �baseando-se no modulo 10. Utilizado para verificar o digito ���
���          �em linhas digitaveis e codigo de barras de concessionarias  ���
���          �de servicos publicos                                        ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mod10( cNum )
	*=====================================================================================================================================*
Local nFor    := 0
Local nTot    := 0
Local cNumAux

// Verifico o numero de digitos e impar
// Caso seja, adiciono um caracter
If Len(cNum)%2 #0
	cNum := "0"+cNum
EndIf

For nFor := 1 To Len(cNum)
	If nFor%2 == 0
		cNumAux := StrZero(2 * Val(SubStr(cNum,nFor,1)), 2)
	Else
		cNumAux := StrZero(Val(SubStr(cNum,nFor,1))    , 2)
	Endif
	nTot += ( Val(LEFT(cNumAux,1)) + Val(Right(cNumAux,1)) )
Next

nTot := nTot % 10
nTot := If( nTot#0, 10-nTot, nTot )

Return Str(nTot,1)
*=====================================================================================================================================*

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �VldMod    �Autor  �Adrianne Furtado    � Data �  28/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de uma sequencia de numeros    ���
���          �verificando qual o modulo do padr�o FEBRABAN deve ser       ���
���          �utilizado                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldMod( cNum , cCodBar)
	*=====================================================================================================================================*
Local cCodSub3 := SubStr(cCodBar,3,1)
Local cRet := ""
If cCodSub3 == '6' .or. cCodSub3 == '7' 
	cRet :=Mod10(cNum)
ElseIf cCodSub3 == '8' .or. cCodSub3 == '9'
	cRet :=Mod11(cNum)
EndIf
Return cRet
*=====================================================================================================================================*

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Mod11     �Autor  �Adrianne Furtado    � Data �  28/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de uma sequencia de numeros    ���
���          �baseando-se no modulo 10. Utilizado para verificar o digito ���
���          �em linhas digitaveis e codigo de barras de concessionarias  ���
���          �de servicos publicos                                        ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mod11( cNum )
	*=====================================================================================================================================*
Local nFor    := Len(cNum)
Local nTot    := 0
Local aNumAux := Array(Len(cNum),3) //array com o conteudo do cNum para ser multiplicado
Local aLisMult:= {9,8,7,6,5,4,3,2} //Array/Lista de Multiplicadores
Local nResto  
Local nDv   
Local nPos 	  := Len(aLisMult)

For nFor := Len(cNum) To 1 Step -1
	aNumAux[nFor,1] := Val(SubStr(cNum,nFor,1))
	aNumAux[nFor,2] := aLisMult[nPos]
	nPos--
	If nPos == 0
		nPos := 8
	EndIf
	aNumAux[nFor,3] := aNumAux[nFor,2] * aNumAux[nFor,1]
	nTot += aNumAux[nFor,3]
Next

nResto := nTot % 11
nDv := 11-nResto

If (nResto == 0 .Or.	nResto == 1)
	nDv := 0
ElseIf nResto == 10
	nDv := 1
Else 
	nDv := 11-nResto
EndIf

Return Str(nDv,1)
*=====================================================================================================================================*
