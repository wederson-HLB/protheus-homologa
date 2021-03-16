#include "rwmake.ch"                                                     
#include "topConn.ch"
#Include "AP5MAIL.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"


/*
Funcao      : GDRFAT
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Enviar e-mail diario com posicao do financeiro.
Autor       : Gestao Dinamica
Data/Hora   : 03/28/12 
TDN         : Não disponivel
Revisão     : 
Data/Hora   : 28/03/12 
Módulo      : Financeiro.
*/




//-----------
User Function GDRFAT01()   // posicao consulting
Private aColRec:={"Consulting","Consultores","Techonology","Pryor RH","Pryor Gestao","Total Geral"}

GDRFATA1('1')

User Function GDRFAT02()  // posicao auditores
Private aColRec:={"Auditores","Corporate Tax","Corporate Advisory","Assessoria","Total Geral"}
GDRFATA1('2')

//--------------------
static Function GDRFATA1(_Gr) 
//--------------------

Private aCob := {}
Private aJur:={}
Private aEMP:={}
Private aRec:={}     
Private aOrc:={}     
                             
Private _nT3:=_nT4:=_nT5:=_nT6:=_nT7:=_nT8:=0

TMPREC(_Gr)  // POSICAO DE RECEITA

TMPSE1(_Gr)  // POSICAO CONTAS A RECEBER CONSULTING

EnvMail(_Gr,iif(_Gr=='1','Consulting','Auditores')) // processa e envia email

                                       
	
Return


//----------------------------
static function EnvMail(_Gr,_cGR)      
//----------------------------                                      
Local _cSubject	:= ""
Local _cTo		:= " "
Local _cHtml		:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli :=''
Local _cSubject := '[GTCORP] - Desempenho '+alltrim(Str(Year(ddatabase)))+' '+_cGr+' em ' + DTOC(date())

_cHtml+='   <html xmlns="http://www.w3.org/1999/xhtml">                                                           '
_cHtml+='   <head>                                                                                                           '
_cHtml+='   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                            '
_cHtml+='   <title>Desempenho GTCORP '+alltrim(Str(Year(ddatabase)))+' '+_cGr+'</title>                                                                                '
_cHtml+='   </head>                                                                                                         '
_cHtml+='                                                                                                                   '
_cHtml+='   <body marginheight="0" marginwidth="0" style="margin:0"><br />                                                  '
_cHtml+='                                                                                                                   '
_cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-family:Arial; font-size:12px; font-weight:normal; color:#000000">                         '
_cHtml+='   <tr>                                                                                                            '
_cHtml+='   <td align="center" valign="top">                                                                                '
_cHtml+='   	<table width="100%" cellpadding="0" cellspacing="0" border="0">                                            '
_cHtml+='   		<tr>                                                                                                  '
_cHtml+='           	<td align="center" valign="middle" bgcolor="#0a4c9d" style="color:#FFFFFF; line-height:50px; font-weight:bold; font-size:16px>Desempenho GTCORP '+alltrim(str(Year(dDatabase)))+' </td>'
_cHtml+='           </tr>                                                                                                   '
_cHtml+='   	</table>                                                                                                       '
_cHtml+='   <table width="94%" cellpadding="0" cellspacing="0" border="0">                                                     '
_cHtml+='   <tr>                                                                                                               '
_cHtml+='   <td>                                                                                                               '
_cHtml+='       <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:12px">                         '
_cHtml+='   		<tr>                                                                                                       '
_cHtml+='           	<td width="80%"></td>                                                                                  '
_cHtml+='               <td width="20%" align="right">emitido em:  '+dtoc(date())+'</td>                                      '
_cHtml+='           </tr>                                                                                                      '
_cHtml+='           <tr>                                                                                      '
_cHtml+='           	<td align="left" style="font-size:14px" ><b>Faturamento Real x Orcado (x1000)</b></td>                                '
_cHtml+='               <td align="right">Fonte: GTCORP ERP Microsiga</td>                                    '
_cHtml+='           </tr>                                                                                     '
_cHtml+='   	</table>                                                                                      '
_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
_cHtml+='<tr bgcolor="#365F91" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td style="font-weight:bold" width="130px" align="center" ></td>                                     '                                       

for i:=1 to Len(aColRec)
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91></td>                   '                                                                          
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91>'+aColRec[i]+'</td>         '                                                                         
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91></td>                    '                                                                        
Next	
                                    

_cHtml+='</tr>                                                                                                '
_cHtml+='<tr bgcolor="#365F91" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td width="131px"></td>                                                                              '
for i:=1 to Len(aColRec)
	_cHtml+='<td width="100px" bgcolor=#365F91>Orcado</td>                                                        '              
	_cHtml+='<td width="100px" bgcolor=#365F91>Real</td>                                                          '           
	_cHtml+='<td width="101px" bgcolor=#365F91>%</td>                                                             '            
Next	

_cHtml+='</tr>                                                                                                '
If _Gr=='1'
   aTotO:={0,0,0,0,0,0}
   aTotR:={0,0,0,0,0,0}                                             `
Else
   aTotO:={0,0,0,0,0}
   aTotR:={0,0,0,0,0}                                             `

Endif
nTotGO:=nTotGR:=0 
lt:=iif(_Gr=='1',6,5)
For l:=1 to 12
	_cHtml+='           <tr>                                                                                                     '
	_cHtml+='        	    <td bgcolor="#365F91" align="left" style="color:#FFFFFF; line-height:24px">'+U_EXECMES(l,'1')+'</td>      '
	
	FOR c:=1 TO Len(aColRec)-1		    	                                      
		_cColor:=iif(aOrc[l][c] > aRec[l][c],'#FF0000','#0000FF') 
        _nVar:=Round(iif(aOrc[l][c]==0,0,(100*(aRec[l][c]/aOrc[l][c]))-100),1)
	    _cHtml+='           <td align="center"> '+TRANS(aOrc[l][c],"@Z 99,999,999")+'</td>  '
	    _cHtml+='           <td align="center"> '+TRANS(aRec[l][c],"@Z 99,999,999")+'</td>  '		
        _cHtml+='           <td align="center" style="color:'+ _cColor +'"> '+IIF(aRec[l][c]>0,TRANS(_nVar,"@Z 9999.9"),'')+'</td>  '
        
        aTotO[c]+=aOrc[l][c]
	    aTotR[c]+=aRec[l][c]
	NEXT	                      
	_cColor:=iif(aOrc[l][lt] > aRec[l][lt],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aOrc[l][lt]==0,0,(100*(aRec[l][lt]/aOrc[l][lt]))-100),1)
    _cHtml+='           <td align="Center">'+TRANS(aOrc[l][lt],"@Z 99,999,999")+'</td>   '
    _cHtml+='           <td align="Center"> '+TRANS(aRec[l][lt],"@Z 99,999,999")+'</td>   '
    _cHtml+='           <td align="center" style="color:'+ _cColor +'"> '+IIF(aRec[l][lt]>0,TRANS(_nVar,"@Z 9999.9"),'')+'</td>  '
	_cHtml+='       </tr>	                                                                '
Next

_cHtml+='        <td bgcolor="#365F91" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" >Total</td>  '                                               

FOR c:=1 TO Len(aColRec)-1		    	                                      
	_cColor:=iif(aTotO[c] > aTotR[c],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotO[c]==0,0,(100*(aTotR[c]/aTotO[c]))-100),1)
    _cHtml+='           <td align="center"> '+TRANS(aTotO[c],"@Z 99,999,999")+'</td>  '
    _cHtml+='           <td align="center"> '+TRANS(aTotR[c],"@Z 99,999,999")+'</td>  '		
    _cHtml+='           <td align="center" style="color:'+ _cColor +'"> '+IIF(aTotR[c]>0,TRANS(_nVar,"@Z 9999.9"),'')+'</td>  '
	nTotGO+=aTotO[c]
	nTotGR+=aTotR[c]
NEXT	                      

_cColor:=iif(nTotGO > nTotGR,'#FF0000','#0000FF') 
_nVar:=Round(iif(nTotGO==0,0,(100*(nTotGR/nTotGO))-100),1)
_cHtml+='           <td align="Center">'+TRANS(nTotGO,"@Z 99,999,999")+'</td>   '
_cHtml+='           <td align="Center"> '+TRANS(nTotGR,"@Z 99,999,999")+'</td>   '
_cHtml+='           <td align="center" style="color:'+ _cColor +'"> '+IIF(nTotGR>0,TRANS(_nVar,"@Z 9999.9"),'')+'</td>        '
_cHtml+='       </tr>                                                                                          '
_cHtml+='   </table>
 
_cHtml+='   <BR> 
_cHtml+='   <BR> 
_cHtml+='   <BR> 
          
//INVOICE / FATURAMENTO PENDENTE



// posicao cobranca
for t:=1 to 1 // 2 juridico nao sai
	_cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-family:Arial; font-size:12px; font-weight:normal; color:#000000">                         '
	_cHtml+='   <tr>                                                                                                            '
	_cHtml+='   <td align="center" valign="top">                                                                                '
	_cHtml+='   	<table width="100%" cellpadding="0" cellspacing="0" border="0">                                            '
	_cHtml+='   		<tr>                                                                                                  '
	_cHtml+='           	<td align="center" valign="middle" bgcolor="#0a4c9d" style="color:#FFFFFF; line-height:50px; font-weight:bold; font-size:16px>Desempenho GTCORP '+alltrim(str(Year(dDatabase)))+' </td>'
	_cHtml+='           </tr>                                                                                                   '
	_cHtml+='   	</table>                                                                                                       '
	_cHtml+='   <table width="94%" cellpadding="0" cellspacing="0" border="0">                                                     '
	_cHtml+='   <tr>                                                                                                               '
	_cHtml+='   <td>                                                                                                               '
	_cHtml+='       <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:14px">                         '
	_cHtml+='           <tr>                                                                                      '
	_cHtml+='           	<td align="left"><b>Posicao Cobranca'+IIF(t==1," "," - JURIDICO")+'</b></td>                                         '
	_cHtml+='           </tr>                                                                                     '
	_cHtml+='   	</table>                                                                                      '
	_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
	_cHtml+='<tr bgcolor="#365F91" align="center" style="color:#FFFFFF; line-height:24px">                '
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" >Empresas </td>                    '                                       
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 10 dias </td>   '                                                                        
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 30 dias </td>   '                                                                    
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 60 dias </td>   '                                                                   
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 90 dias </td>   '                                                                    
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> > 90 dias </td>   '                       
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91>Total Geral</td>   '                                             
	_nT3:=_nT4:=_nT5:=_nT6:=_nT7:=_nT8:=0
	For i:=1 to len(IIF(t==1,aCob,aJur))	
		_cHtml+='   <tr>                                                                                                   '
		_cHtml+='      <td bgcolor="#365F91" align="left" style="color:#FFFFFF; line-height:24px"><b>'+aCob[i][1]+'-'+aCob[i][2]+'</b></td>      '
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][3],aJur[i][3]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][4],aJur[i][4]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][5],aJur[i][5]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][6],aJur[i][6]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][7],aJur[i][7]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][8],aJur[i][8]),"@R 99,999,999")+'</td>                               '			
		_cHtml+=    ' </tr>                                                                                            '
	    _nT3+=IIF(t==1,aCob[i][3],aJur[i][3])
	    _nT4+=IIF(t==1,aCob[i][4],aJur[i][4])
	    _nT5+=IIF(t==1,aCob[i][5],aJur[i][5])
	    _nT6+=IIF(t==1,aCob[i][6],aJur[i][6])
	    _nT7+=IIF(t==1,aCob[i][7],aJur[i][7])
	    _nT8+=IIF(t==1,aCob[i][8],aJur[i][8])
	Next
	_cHtml+=    ' <tr>                                                                                            '
	_cHtml+='        <td bgcolor="#365F91" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Right" >Total</td>                   '                                               
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT3,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT4,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT5,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT6,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT7,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT8,"@R 99,999,999")+'</td>    '	
	_cHtml+=    ' </tr>                                                                                            '
    _cHtml+=' </table> 
    _cHtml+=' <BR> 
    _cHtml+=' <BR> 
Next	

// fim posicao cobranca

_cHtml+=' </body>                                                               '
_cHtml+=' </html>                                                               '
       
_nENVIA:=0    // TENTA ENVIAR EMAIL 6 VEZES ATE R                                                                                                      

DO WHILE _nENVIA<5
   IF ENVIA(_cTo, _cHtml, _cSubject)                                                                                                      
      EXIT
   ENDIF
   _nENVIA++
   Alert("Pressione <Enter> para nova tentativa de envio do e-mail"+str(_nEnvia,1)+"/6")   
ENDDO                                                                                                                      
	
Return                         


static Function ENVIA(_cTo, _cHtml,_cSubject)

Local cServer  := ALLTRIM(GetMv("MV_RELSERV")) // Nome do servidor de envio de e-mail
Local cAccount := ALLTRIM(GetMv("MV_RELACNT")) // Conta a ser utilizada no envio de e-mail
Local cPassword:= ALLTRIM(GetMv("MV_RELPSW")) // Senha da conta de e-mail para envio
Local cDe      := ALLTRIM(GetMv("MV_RELACNT"))
Local cPara    := _cTo
Local cCC      := ""
Local cBCC     := ""
Local cAssunto := _cSubject 
Local cNomeArq := ""
Local cAnexo   := ""//_cHtml
Local cDescricao
Local cSaudacao
Local cMsg 	   := _cHtml
Local lAutentica := GetMv("MV_RELAUTH")        //Determina se o Servidor de Email necessita de Autentica\E7\E3o
Local lEnviado := .T.
/*
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk

If lOk
   ConOut("Servidor de e-mail conectado!")
Endif

If lAutentica
   if !MailAuth(cAccount,cPassword)
      APMSGALERT("Erro de Autentica\E7\E3o")
      DISCONNECT SMTP SERVER
      ConOut("Servidor de e-mail desconectado!")
      lEnviado:=.F.
   Else      
      SEND MAIL FROM cDe;
                  TO cPara;
                  CC cCC;
          BCC cBCC;
             SUBJECT cAssunto;
               BODY cMsg;
          ATTACHMENT cAnexo;
              RESULT lEnviado
      If lEnviado
        APMSGALERT("E-mail enviado com sucesso!")
      Else
        cMensagem := ""
        GET MAIL ERROR cMensagem 
        APMSGALERT(cMensagem)
      Endif

      DISCONNECT SMTP SERVER Result lDisconectou
   
      if lDisconectou
        ConOut("Servidor de e-mail desconectado!")
      Endif
   Endif
Endif                                
*/
ENVIA_EMAIL("","Desempenho Gerencial",cAssunto,cMsg,.F.,_cTo,"")

Return(lENVIADO)    


                



User function EXECMES(_nMes,_Gr)

Local _nMes
Local _cRet  

IF _nMes == 1
	_cRet:= IIF(_Gr=='1',"OUT","JAN")
Elseif _nMes == 2
	_cRet:= IIF(_Gr=='1',"NOV","FEV")
Elseif _nMes == 3
	_cRet:= IIF(_Gr=='1',"DEZ","MAR")
Elseif _nMes == 4
	_cRet:= IIF(_Gr=='1',"JAN","ABR")
Elseif _nMes == 5
	_cRet:= IIF(_Gr=='1',"FEV","MAI")
Elseif _nMes == 6
	_cRet:= IIF(_Gr=='1',"MAR","JUN")
Elseif _nMes == 7
	_cRet:= IIF(_Gr=='1',"ABR","JUL")	
Elseif _nMes == 8
	_cRet:= IIF(_Gr=='1',"MAI","AGO")	
Elseif _nMes == 9
	_cRet:= IIF(_Gr=='1',"JUN","SET")	
Elseif _nMes == 10
	_cRet:= IIF(_Gr=='1',"JUL","OUT")	
Elseif _nMes == 11
	_cRet:= IIF(_Gr=='1',"AGO","NOV")	          
Elseif _nMes == 12
	_cRet:= IIF(_Gr=='1',"SET","DEZ")	
Endif
			
Return(_cRet)                                


//-------------------------
STATIC FUNCTION TMPSE1(_Gr)
//-------------------------
Local cQuery       := ""
Local xAliasSM0   := SM0->(GetArea())
Local i        := 0
Local aCampos := {}
Local _xRec:=SM0->(Recno())
 
/*
aCob[1][1]  codigo empresa
aCob[1][2]  nome empresa
aCob[1][3]  <10 dias
aCob[1][4]  <30 dias
aCob[1][5]  <60 dias
aCob[1][6]  <90 dias
aCob[1][7]  <=90 dias                                               
aCob[1][8]  total                                               

// empresas eliminadas
Z6-PRYOR AUDITORES


// grupo consultores
CH-GT TECHONOLOGY 
RH-PRYOR RH 
Z4-GT BPO 
Z8-GT CONSULTORES 
ZP-PRYOR GESTAO 

// grupo auditores
ZB-GT AUDITORES 
ZF-GT CORPORATE 
ZG-GT CONSULTORIA 

*/


SM0->(DbGoTop())
aCob:={}                  
aJur:={}
While SM0->(!EOF())    
	If SM0->M0_CODIGO $ IIF(_Gr=='1','CH,RH,Z4,Z8,ZP','ZG,ZB,ZF')
		nPos := aScan( aCob , { |x| x[1] == SM0->M0_CODIGO } )
		IF nPos == 0
		   Aadd( aCob , { SM0->M0_CODIGO , IIF(Alltrim(SM0->M0_CODIGO)=='Z4','GT CONSULTING',SM0->M0_NOME),0,0,0,0,0,0})   //	Aadd( aCob , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
		   Aadd( aJur , { SM0->M0_CODIGO , IIF(Alltrim(SM0->M0_CODIGO)=='Z4','GT CONSULTING',SM0->M0_NOME),0,0,0,0,0,0})   //	Aadd( aCob , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
		EndIF
	EndIF
	SM0->(DbSkip())
EndDo


For i := 1 To Len(aCob)
	
	cQuery:= "SELECT    '" + aCob[i,1] + "' AS EMPRESA,                                                                            "
	cQuery+= " datediff(day,E1_VENCTO,getdate()) as Dias, "
	cQuery+= " E1_SITUACA, "
	cQuery+= " ROUND(E1_SALDO,2) AS VALOR                         "
	cQuery+= "FROM SE1" + aCob[i,1] + "0     "
	cQuery+= " WHERE E1_FLUXO<>'N'  AND D_E_L_E_T_='' AND E1_TIPO='NF' AND E1_SALDO>0 AND E1_VENCTO <  '"+DTOS(DDATABASE)+"'"

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP1",.F.,.T.)
	
	DbSelectArea("TMP1")             
	TMP1->(DbGotop())
	While !TMP1->(Eof())

		nPos := aScan( aCob , { |x| x[1] == TMP1->EMPRESA } )
        IF nPOS>0
			If TMP1->DIAS <= 10
                IF TMP1->E1_SITUACA<>'6'
				   aCob[nPos][3]+=Round(TMP1->VALOR,2)
				ELSE
				   aJur[nPos][3]+=Round(TMP1->VALOR,2)
				ENDIF
			EndIf
			If TMP1->DIAS <= 30 .AND. TMP1->DIAS > 10
                IF TMP1->E1_SITUACA<>'6'
				   aCob[nPos][4]+=Round(TMP1->VALOR,2)
				ELSE
				   aJur[nPos][4]+=Round(TMP1->VALOR,2)
				ENDIF
			EndIf
			If TMP1->DIAS <= 60 .AND. TMP1->DIAS > 30
                IF TMP1->E1_SITUACA<>'6'
				   aCob[nPos][5]+=Round(TMP1->VALOR,2)
				ELSE
				   aJur[nPos][5]+=Round(TMP1->VALOR,2)
				ENDIF
			EndIf
			If TMP1->DIAS <= 90 .AND. TMP1->DIAS > 60
                IF TMP1->E1_SITUACA<>'6'
				   aCob[nPos][6]+=Round(TMP1->VALOR,2)
				ELSE
				   aJur[nPos][6]+=Round(TMP1->VALOR,2)
				ENDIF
			EndIf
			If TMP1->DIAS > 90
                IF TMP1->E1_SITUACA<>'6'
				   aCob[nPos][7]+=Round(TMP1->VALOR,2)
				ELSE
				   aJur[nPos][7]+=Round(TMP1->VALOR,2)
				ENDIF
			EndIf
            IF TMP1->E1_SITUACA<>'6'
	           aCob[nPos][8]+=Round(TMP1->VALOR,2)
			ELSE
			   aJur[nPos][8]+=Round(TMP1->VALOR,2)
			ENDIF
        ENDIF
        TMP1->(DBSkip()) 
	END          	
	TMP1->(DbCloseArea())
Next
SM0->(DbGoto(_xRec))
Return(aCob)



//receitas//
//-------------------------
//-------------------------
STATIC FUNCTION TMPREC(_Gr)
//-------------------------
Local cQuery       := ""
Local xAliasSM0   := SM0->(GetArea())
Local i        := 0
Local aCampos := {}
Local _xRec:=SM0->(Recno())                         
Local dDatai
Local dDataf

//IF _Gr=='1'  // CONSULTING 01/10/12 A 30/9/12 
	dDatai:=ctod('01/10/'+str(year(dDatabase)-1))
	dDataf:=ctod('30/09/'+str(year(dDatabase)))
//ELSE  // AUDITORES 01/01/ANO A 31/12/ANO
//    dDatai:=ctod('01/01/'+str(year(dDatabase)))
//    dDataf:=ctod('31/12/'+str(year(dDatabase)))
//ENDIF	 
/*
aCob[1][1]  codigo empresa
aCob[1][2]  nome empresa
aCob[1][3]  orcado
aCob[1][4]  real
aCob[1][5]  

// empresas eliminadas
Z6-PRYOR AUDITORES


// grupo consultores
CH-GT TECHONOLOGY 
RH-PRYOR RH 
Z4-GT BPO 
Z8-GT CONSULTORES 
ZP-PRYOR GESTAO 
IIF(aEMP[X]=='Z4',1,IIF(aEMP[X]=='Z8',2,IIF(aEMP[X]=='CH',3,IIF(aEMP[X]=='RH',4,IIF(aEMP[X]=='ZP',5,0)))))
// grupo auditores
ZB-GT AUDITORES 
ZF-GT CORPORATE 
ZG-GT CONSULTORIA 

*/

SM0->(DbGoTop())
aEmp:={}
While SM0->(!EOF())    
	If SM0->M0_CODIGO $ IIF(_Gr=='1','CH,RH,Z4,Z8,ZP','ZG,ZB,ZF')
		nPos := aScan( aEmp , { |x| x[1] == SM0->M0_CODIGO } )
		IF nPos == 0
		   Aadd( aEmp , { SM0->M0_CODIGO , IIF(Alltrim(SM0->M0_CODIGO)=='Z4','GT CONSULTING',SM0->M0_NOME),0,0,0})   //	Aadd( aCob , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
		EndIF
	EndIF
	SM0->(DbSkip())
End


aRec:={}                           

If _Gr=='1'
	AADD(aOrc,{4029334.64,  394283.72,  64474.13,  122758.32,  243389.70, 0})
	AADD(aOrc,{5451915.48,  405323.66,  66085.98,  122758.32,  243389.70, 0})							
	AADD(aOrc,{5569199.91,  416672.72,  67738.13,  122758.32,  243389.70, 0})
	AADD(aOrc,{4435309.95,  428339.56,  69431.59,  122758.32,  243389.70, 0})
	AADD(aOrc,{4585918.43,  440333.07,  71167.38,  122758.32,  243389.70, 0})	
	AADD(aOrc,{4742360.24,  452662.39,  72946.56,  122758.32,  243389.70, 0})	
	AADD(aOrc,{4904863.37,  465336.94,  74770.22,  122758.32,  243389.70, 0})
	AADD(aOrc,{6238416.00,  478366.37,  76639.48,  122758.32,  243389.70, 0})
	AADD(aOrc,{6185274.15,  491760.63,  78555.47,  122758.32,  243389.70, 0})
	AADD(aOrc,{5431157.35,  505529.93,  80519.35,  122758.32,  243389.70, 0})
	AADD(aOrc,{5620370.52,  519684.77,  82532.34,  122758.32,  243389.70, 0})	
	AADD(aOrc,{5816926.85,  534235.94,  84595.65,  122758.32,  243389.70, 0})	
	AADD(aOrc,{63011046.89, 5532529.69, 889456.27, 1473099.84, 2920676.40,0})
Endif         
               

for i:=1 to 12
	If _Gr=='1'
		AADD(aRec,{0,0,0,0,0,0})
	      
		// divisao por 1000
		For a:=1 to len(aColRec)-1
		    aOrc[i][a]:=aOrc[i][a]/1000
		Next		
        aOrc[i][6]:=aOrc[i][1]+aOrc[i][2]+aOrc[i][3]+aOrc[i][4]+aOrc[i][5]
	Else
		AADD(aRec,{0,0,0,0,0})
		AADD(aOrc,{0,0,0,0,0})
	Endif
Next


For nX := 1 To Len(aEmp)
	
	cQuery:= "SELECT MONTH(E1_EMISSAO) AS MES,                                                               "
	cQuery+= "  ROUND(SUM(E1_VALOR/1000),1,2) AS VALOR                                                       "
	cQuery+= "FROM SE1" + aEmp[nX,1] + "0                                                                    "
	cQuery+= "  WHERE D_E_L_E_T_=''   AND E1_TIPO = 'NF'                                                     "
	cQuery+= "	AND E1_SERIE<>'ND ' AND E1_FLUXO<>'N' AND E1_EMISSAO BETWEEN '"+DTOS(dDATAI)+"' AND '"+DTOS(dDATAF)+"'                            "
	cQuery+= "                                                                                               "
	cQuery+= "GROUP BY MONTH(E1_EMISSAO)                                                                     "
	                                                                                  
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP1",.F.,.T.)
	
	DbSelectArea("TMP1")
	TMP1->(DbGotop()) 
    IF _Gr=='1'
       cCOLUNA:=IIF(aEMP[nX][1]=='Z4',1,IIF(aEMP[nX][1]=='Z8',2,IIF(aEMP[nX][1]=='CH',3,IIF(aEMP[nX][1]=='RH',4,IIF(aEMP[nX][1]=='ZP',5,'0')))))	
    Else 
       cCOLUNA:=IIF(aEMP[nX][1]=='ZB',1,IIF(aEMP[nX][1]=='ZF',2,IIF(aEMP[nX][1]=='ZG',4,'0')))	
    
    Endif
	While !TMP1->(Eof())
	    cMes:=TMP1->MES
	    //IF cMes <=iif(_Gr=='1',5,4) .AND. !EMPTY(cMes)
           //If _GR=='1'
              cMes:=IIF(cMES>9,cMES-9,cMES+3)  // AJUSTE PARA INICIAR A 1A COLUNA EM OUTUBRO QDO FOR CONSULTING
           //Endif
           aRec[cMes][cColuna]+=TMP1->VALOR
           aRec[cMes][iif(_Gr=='1',6,5)]+=TMP1->VALOR
        //ENDIF
        TMP1->(DBSkip()) 
	END          	
	TMP1->(DbCloseArea())
Next
SM0->(DbGoto(_xRec))
Return(aRec)
