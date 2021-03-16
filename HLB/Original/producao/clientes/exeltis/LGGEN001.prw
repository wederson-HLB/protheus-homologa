#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
/*
Funcao      : LGGEN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Etiqueta de Caixa
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014
Obs         :
Revisão     : João Vitor | Infinot
Data/Hora   : 13/02/2016
Revisão     : Richard S Busso
Data/Hora   : 03/08/2017
Módulo      : Faturamento.
Cliente     : Exeltis
*/

//*-----------------------------------------------------------------------------------------------*
User Function LGGEN001(cPorta, cVolume,cQemb,cUm,cDtFab,cDtVal,cProduto,cLote,cDescr,_cCB)
//*-----------------------------------------------------------------------------------------------*
	
	If SB1->(dbseek(xFilial("SB1")+cProduto))
		cDescr	:= Alltrim(SB1->B1_DESC)
		If EMPTY(SB1->B1_P_DUN14)
			MSCBPRINTER("S4M",cPorta,,,.f.,,,,) // Configura e define a porta na impressora Zebra S-600
			MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
			MSCBWrite("CT~~CD,~CC^~CT~")
			MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
			MSCBWrite("^XA")
			MSCBWrite("^MMT")
			MSCBWrite("^PW799")
			MSCBWrite("^LL0400")
			MSCBWrite("^LS0")
			MSCBWrite("^FO0,0^GFA,04096,04096,00032,:Z64:")
			MSCBWrite("eJztlr1v20YYh++OZMQyQGoBEtBCAwlOBodMHQoJiBVAGQPYQAgnA7cMQfeiixGd3KEXTe3WbIQn4pAhIxEtDDLkL9BWoUKyBJqUqSqgmn2Pxy8p8XEwuhQ5WZJ9rx/93s87IfRlfVn//aJqM07UdhKq7cax2m5Fanv3j+vx/gO13eMNfECVds6Vduz7Q5WdeDxs4BMlz9W84fvKAhC3kX+ospucKwvQ9dUFIK7XxCsbAPSVBfQb9F3XbeJ9pf60UV/JE0gAbeBVdsaUDYgFP1Q5APFfhzfZ9Hr6xHX3dm6Vvxn+3c/wdqXHQwYJCHftvdJu+L7kj9Kt3DlKzuq864kEhMhbfZAbXvIEeXV+/hm+kmI8ggSEaDCL5caAfo+smv+FftGELeD1evAcng7yyg16WIsE+MU844sdwdcWFJ+xKET9YkMD/R0+15d/6zmPyyMBpt+R+p54UJL88GFFrTwbUL2g0LfRGU7XrWS8SelRmuPQ/RFjVOj3aKzNYo0O4hkdvCr5Ut+mm1a6Af7vlI4LHo6vCJFM/xaNSBjdoLed2/QFKfnFIudbr9dfJ2fCf3uyxkX8WQIyfW0S3qR9jfZRb/ISfaqvvV/a6E7OVymC6XUg+IuQvFtayIP4kUWXFR8Esv5r/FdiI3ufN6X+YBbimZCW+nFhlvrQNukSp+hOwW/r+hSJSyhEHLJgEQovtJwoP2sAlNVvXPJ0XDogpp+hrP59eAwyfahBbu768vwT/FOIPpW8fVnqe1IfniuYgpWMn6wqPpjnfCqmQPK4rJ8F8ZtSH8o+C6U+jEHecJU+Fm2TSL4aQc4LfcIp3ARQf+gEcEGajfliPj/OeO0t5B/lfIuW8pzSTF/7OeyJ/s/0NVr6/6M4PkT/vFkLMHla52v61vkSApfxF/qi/gtxfIv+xdB/N4DX7Qkt/Be3D6Qf6v+qh2Mt7mvR4Pfeb/Gg7B//NOPTSxunv6SXre14a39M6/m7oKIK3EP8nHMSeZEVFleKmP9/svjTyzM0nqRbvLE3rY9p2UBw+8D4C/0Y4oYujG++1MKi/sCf/nRaDLteP3mq+ivuf+CDPxfJlXaZAHq1OYt/qOCFvnO1tQvzv1DyMv6rliHqr/z+A7xCH779BQvgD5B58M0Q8of3Ukiiqai/hRiCMYCfvQ+DDngAfLs78vE93dBPfL092vkAeVuYU3fqTQlz3PPD6U4Agbg52vqzzsPRif7rV/ojo13nWaZPXIYsh5oXpmOaewkQ4Xe+w53R4xO9c3d0fK+742HmMHEYsRyCQubs4AXfPnjWeST0n+vB/W/r/2BS+WYi02EmO3SIY9XMuq8Pq2Qg9SKfbhnHuOI7Dfz/a/0Lhw2iMQ==:3417")
			MSCBWrite("^FO15,7^GB783,269,8^FS")
			MSCBWrite("^FO16,126^GB782,0,8^FS")
			MSCBWrite("^FO477,7^GB0,126,4^FS")
			MSCBWrite("^FO239,7^GB0,122,4^FS")
			MSCBWrite("^FO239,63^GB558,0,8^FS")
			MSCBWrite("^FO631,9^GB0,59,4^FS")
			MSCBWrite("^FO348,10^GB0,58,4^FS")
			MSCBWrite("^FT484,86^A0N,14,14^FH\^FDLOTE:^FS")
			MSCBWrite("^FT637,30^A0N,14,14^FH\^FDVENCIMENTO:^FS")
			MSCBWrite("^FT481,30^A0N,14,14^FH\^FDFABRICACAO:^FS")
			MSCBWrite("^FT440,54^A0N,14,14^FH\^FD"+cUm+"^FS")
			MSCBWrite("^FT355,32^A0N,14,14^FH\^FDQT DE Emb:^FS")
			MSCBWrite("^FT245,86^A0N,14,14^FH\^FDPRODUTO:^FS")
			MSCBWrite("^FT245,32^A0N,14,14^FH\^FDVolume:^FS")
//			MSCBWrite("^BY5,3,50^FT68,221^BCN,,Y,N")
			MSCBWrite("^FT249,57^A0N,23,24^FH\^FD"+cVolume+"^FS")
			MSCBWrite("^FT358,58^A0N,23,24^FH\^FD"+cQemb+"^FS")
			MSCBWrite("^FT493,57^A0N,23,24^FH\^FD"+cDtFab+"^FS")
			MSCBWrite("^FT661,56^A0N,23,24^FH\^FD"+cDtVal+"^FS")
			MSCBWrite("^FT534,114^A0N,42,40^FH\^FD"+cLote+"^FS")
			MSCBWrite("^FT270,118^A0N,28,28^FH\^FD"+cProduto+"^FS")
			MSCBWrite("^FT36,163^A0N,28,28^FH\^FD"+SubStr(cDescr,1,30)+"^FS")
		//	MSCBWrite("^BY2,3,51^FT18,337^B3N,N,,Y,N")
		//	MSCBWrite("^FD"+AllTrim(_cCB)+"-"+AllTrim(cQemb)+"-"+AllTrim(cLote)+"^FS")
		//	MSCBWrite("^PQ1,0,1,Y^XZ")
			MSCBWrite("^BY3,3,75^FT36,356^BCN,,Y,N")
			MSCBWrite("^FD>;"+AllTrim(_cCB)+">6-"+AllTrim(cQemb)+"->5"+AllTrim(cLote)+"^FS")
			MSCBWrite("^PQ1,0,1,Y^XZ")
			MSCBWrite("^XA^ID000.GRF^FS^XZ")			
			MSCBEND()
			MSCBCLOSEPRINTER()
		Else //Impressão com DUM14
			MSCBPRINTER("S4M",cPorta,,,.f.,,,,) // Configura e define a porta na impressora Zebra S-600
			MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
			MSCBWrite("CT~~CD,~CC^~CT~")
			MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
			MSCBWrite("^XA")
			MSCBWrite("^MMT")
			MSCBWrite("^PW799")
			MSCBWrite("^LL0400")
			MSCBWrite("^LS0")
			MSCBWrite("^FO0,0^GFA,04096,04096,00032,:Z64:")
			MSCBWrite("eJztlr1v20YYh++OZMQyQGoBEtBCAwlOBodMHQoJiBVAGQPYQAgnA7cMQfeiixGd3KEXTe3WbIQn4pAhIxEtDDLkL9BWoUKyBJqUqSqgmn2Pxy8p8XEwuhQ5WZJ9rx/93s87IfRlfVn//aJqM07UdhKq7cax2m5Fanv3j+vx/gO13eMNfECVds6Vduz7Q5WdeDxs4BMlz9W84fvKAhC3kX+ospucKwvQ9dUFIK7XxCsbAPSVBfQb9F3XbeJ9pf60UV/JE0gAbeBVdsaUDYgFP1Q5APFfhzfZ9Hr6xHX3dm6Vvxn+3c/wdqXHQwYJCHftvdJu+L7kj9Kt3DlKzuq864kEhMhbfZAbXvIEeXV+/hm+kmI8ggSEaDCL5caAfo+smv+FftGELeD1evAcng7yyg16WIsE+MU844sdwdcWFJ+xKET9YkMD/R0+15d/6zmPyyMBpt+R+p54UJL88GFFrTwbUL2g0LfRGU7XrWS8SelRmuPQ/RFjVOj3aKzNYo0O4hkdvCr5Ut+mm1a6Af7vlI4LHo6vCJFM/xaNSBjdoLed2/QFKfnFIudbr9dfJ2fCf3uyxkX8WQIyfW0S3qR9jfZRb/ISfaqvvV/a6E7OVymC6XUg+IuQvFtayIP4kUWXFR8Esv5r/FdiI3ufN6X+YBbimZCW+nFhlvrQNukSp+hOwW/r+hSJSyhEHLJgEQovtJwoP2sAlNVvXPJ0XDogpp+hrP59eAwyfahBbu768vwT/FOIPpW8fVnqe1IfniuYgpWMn6wqPpjnfCqmQPK4rJ8F8ZtSH8o+C6U+jEHecJU+Fm2TSL4aQc4LfcIp3ARQf+gEcEGajfliPj/OeO0t5B/lfIuW8pzSTF/7OeyJ/s/0NVr6/6M4PkT/vFkLMHla52v61vkSApfxF/qi/gtxfIv+xdB/N4DX7Qkt/Be3D6Qf6v+qh2Mt7mvR4Pfeb/Gg7B//NOPTSxunv6SXre14a39M6/m7oKIK3EP8nHMSeZEVFleKmP9/svjTyzM0nqRbvLE3rY9p2UBw+8D4C/0Y4oYujG++1MKi/sCf/nRaDLteP3mq+ivuf+CDPxfJlXaZAHq1OYt/qOCFvnO1tQvzv1DyMv6rliHqr/z+A7xCH779BQvgD5B58M0Q8of3Ukiiqai/hRiCMYCfvQ+DDngAfLs78vE93dBPfL092vkAeVuYU3fqTQlz3PPD6U4Agbg52vqzzsPRif7rV/ojo13nWaZPXIYsh5oXpmOaewkQ4Xe+w53R4xO9c3d0fK+742HmMHEYsRyCQubs4AXfPnjWeST0n+vB/W/r/2BS+WYi02EmO3SIY9XMuq8Pq2Qg9SKfbhnHuOI7Dfz/a/0Lhw2iMQ==:3417")
			MSCBWrite("^FO15,7^GB783,269,8^FS")
			MSCBWrite("^FO16,126^GB782,0,8^FS")
			MSCBWrite("^FO477,7^GB0,126,4^FS")
			MSCBWrite("^FO239,7^GB0,122,4^FS")
			MSCBWrite("^FO239,63^GB558,0,8^FS")
			MSCBWrite("^FO631,9^GB0,59,4^FS")
			MSCBWrite("^FO348,10^GB0,58,4^FS")
			MSCBWrite("^FT484,86^A0N,14,14^FH\^FDLOTE:^FS")
			MSCBWrite("^FT637,30^A0N,14,14^FH\^FDVENCIMENTO:^FS")
			MSCBWrite("^FT481,30^A0N,14,14^FH\^FDFABRICACAO:^FS")
			MSCBWrite("^FT440,54^A0N,14,14^FH\^FD"+cUm+"^FS")
			MSCBWrite("^FT355,32^A0N,14,14^FH\^FDQT DE Emb:^FS")
			MSCBWrite("^FT245,86^A0N,14,14^FH\^FDPRODUTO:^FS")
			MSCBWrite("^FT245,32^A0N,14,14^FH\^FDVolume:^FS")
			MSCBWrite("^BY5,3,50^FT68,221^BCN,,Y,N")
			MSCBWrite("^FD>;>8"+Alltrim(SB1->B1_P_DUN14)+"^FS")
			MSCBWrite("^FT249,57^A0N,23,24^FH\^FD"+cVolume+"^FS")
			MSCBWrite("^FT358,58^A0N,23,24^FH\^FD"+cQemb+"^FS")
			MSCBWrite("^FT493,57^A0N,23,24^FH\^FD"+cDtFab+"^FS")
			MSCBWrite("^FT661,56^A0N,23,24^FH\^FD"+cDtVal+"^FS")
			MSCBWrite("^FT534,114^A0N,42,40^FH\^FD"+cLote+"^FS")
			MSCBWrite("^FT270,118^A0N,28,28^FH\^FD"+cProduto+"^FS")
			MSCBWrite("^FT36,163^A0N,28,28^FH\^FD"+SubStr(cDescr,1,30)+"^FS")
//			MSCBWrite("^BY2,3,51^FT18,337^B3N,N,,Y,N")
//			MSCBWrite("^FD"+AllTrim(_cCB)+"-"+AllTrim(cQemb)+"-"+AllTrim(cLote)+"^FS")
//			MSCBWrite("^PQ1,0,1,Y^XZ")
			MSCBWrite("^BY3,3,75^FT36,356^BCN,,Y,N")
			MSCBWrite("^FD>;"+AllTrim(_cCB)+">6-"+AllTrim(cQemb)+"->5"+AllTrim(cLote)+"^FS")
			MSCBWrite("^PQ1,0,1,Y^XZ")
			MSCBWrite("^XA^ID000.GRF^FS^XZ")	
			MSCBEND()
			MSCBCLOSEPRINTER()
		EndIf
	EndIf
	
Return
