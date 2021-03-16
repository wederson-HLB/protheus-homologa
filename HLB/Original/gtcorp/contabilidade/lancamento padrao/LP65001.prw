#include "totvs.ch"
/*                                                                                                          
Funcao      : LP65001
Parametros  : 
Retorno     : cRet
Objetivos   : Retornar a conta de débito depentendo do centro de custo e produto.
Autor       : Jean Victor Rocha
Data        : 10/02/2017
*/
*---------------------*
User Function LP65001()
*---------------------*
Local cRet := ""

//Grupos de Centros de Custos  

Private cCentro1 := "8103|3111|3112|3113|3114|3176|3177|3178|3196|2107|3115|3120|3130|3140|4351|2101|3150|2100|3118|3119|3171|3600|"
cCentro1 += "3601|3603|3606|3180|6101|6161|3172|3198|3195|8101|3199|2002|3173|3174|6173|6174|7101|7190|7301|7311|7321|7331|7107|"
cCentro1 += "7401|7421|7422|7423|7501|7599|7601|7104|7304|7404|7109|7110|7103|7303|7105|7305|7333|7335|7106|7306|7406|6171|8500|"
cCentro1 += "7111|7307|7102|7302|7312|7332|7402|7108|7801|8100|8010|8000|2001|3611|3612|6100|6103|6104|6105|6110|6130|6140|6150|"
cCentro1 += "1107|1140|2105|3110|3116|3117|3125|3151|3175|3179|3181|3190|3197|3604|3605|3607|3610|6160|"
Private cCentro2 := "2102|2103|7195|7395|745|7595|7695|7904|1202|1203|2106|7211|7212|7214|"
Private cCentro3 := "1101|1105|1110|1102|1106|1103|1108|3602|6102|7900|7905|7902|7903|7908|7901|7999|7399|7499|7699|7199|1000|1111|1100|1112|3608|3609|7100|"

//Grupos de Produtos de acordo com a Descrição da moeda
//Bens de Natureza Permanente
Private cProd1 := "P0000178|P0000179|P000250|P00238|P0051|P0054|P0055|P0074|P0080|P0086|P00905|P0096|P01129|P01135|P01136|P01137|P01139|"
//Materiais Auxiliares de Consumo
Private cProd2 := "P00102|P0089|P0102|P0103|P0104|P0105|P0106|P0107|P0108|P0109|P0110|P0111|P01116|P01117|P01118|P01119|"
//Copa, Cozinha e Refeitorio
Private cProd3 := "P0000180|P000025|P0000342|P000037|P000043|P000046|P000048|P000050|P000051|P000052|P000059|P000060|P000063|P000104|P000105|"
cProd3 += "P000108|P000209|P000210|P000211|P000212|P000213|P000214|P000215|P000216|P000217|P000221|P000230|P000231|P00105|P00127|"
cProd3 += "P00128|P00129|P00230|P00231|P00232|P00234|P00235|P0050|P0064|P0077|P01134|DE000002|"
//Higiene e limpeza
Private cProd4 := "DE000099|P0000181|P0000341|P0000343|P0000344|P0000345|P0000346|P000047|P000070|P000071|P000072|P000073|P000074|P000075|"
cProd4 += "P000076|P000077|P000078|P000079|P000096|P000106|P000107|P000109|P000110|P000111|P000112|P000113|P000222|P000223|P000224|"
cProd4 += "P000225|P000226|P000227|P000228|P000300|P000301|P000302|P00031|P00032|P00034|P001121|P00113|P00114|P00115|P00117|P00118|"
cProd4 += "P00119|P00123|P00233|P01140|P0088|DE000081|"
//Material de Escritorio
Private cProd5 := "P000001|P000002|P000005|P000009|P000010|P000011|P000012|P000013|P000014|P000015|P000016|P000017|P000018|P000019|P000020|"
cProd5 += "P000021|P000022|P000023|P000024|P000026|P000027|P000028|P000029|P000030|P000031|P000032|P000033|P000034|P000035|P000036|"
cProd5 += "P000038|P000039|P000040|P000041|P000042|P000044|P000045|P000049|P000054|P000057|P000058|P000061|P000062|P000064|P000065|"
cProd5 += "P000066|P000080|P000083|P000100|P000101|P000102|P000103|P000114|P000118|P000119|P000120|P000121|P000122|P000123|P000124|"
cProd5 += "P000179|P000180|P000181|P000182|P000183|P000184|P000185|P000186|P000187|P000188|P000189|P000190|P000191|P000192|P000193|"
cProd5 += "P000194|P000195|P000196|P000197|P000198|P000199|P000200|P000201|P000202|P000203|P000204|P000205|P000206|P000207|P000208|"
cProd5 += "P000218|P000219|P000220|P000229|P000232|P000233|P00033|P000334|P00067|P00087|P00089|P00090|P00091|P00092|P00093|P00094|"
cProd5 += "P00095|P00096|P00097|P00098|P00099|P00106|P00107|P00108|P00109|P00110|P00111|P00112|P00116|P00124|P00204|P00205|P00206|"
cProd5 += "P00242|P0056|P0060|P0062|P0063|P0065|P0066|P0073|P0075|P0078|P0084|P0091|P0092|P0093|P0094|P0097|P0101|P01115|P01120|"
cProd5 += "P01121|P01126|P01127|P01131|P01138|O000179|DE000001|DE000110|"
//Advogados
Private cProd6 := "DE000035|DE000036|"
//Outros Servicos Profissionais
Private cProd7 := "DE000042|DE000050|DE000051|DE000060|DE000083|DE000087|DE000088|"
//Auditoria
Private cProd8 := "DE000037|DE000059|"
//CONDUCOES
Private cProd9 := "DE000004|DE000101|DE000120|"
//Feiras e Eventos
Private cProd10 := "DE000020|DE000067|"
//Propaganda e publicidade
Private cProd11 := "DE000006|DE000100|"
//Informatica
Private cProd12 := "DE000071|DE000095|DE000150|"
//Manutencao Predial
Private cProd13 := "P00243|P0083|DE000048|DE000028|"
//Fretes e Carretos
Private cProd14 := "P0000099|P00244|"
//LANCHES E REFEICOES
Private cProd15 := "DE000019|P0090|"
//Telefone e fax
Private cProd16 := "DE000038|DE000104|"
//Cursos e Treinamentos
Private cProd17 := "DE000022|DE000023|"
//COPIADORAS
Private cProd18 := "DE000011|DE000013|"
//INTERNET / COMUNICACAO DE DADOS
Private cProd19 := "DE000085|DE000102|"
//Agua e Esgoto
Private cProd20 := "DE000065|"
//Aluguel
Private cProd21 := "DE000015|DE000014|"
//ALUGUEL DE EQUIPAMENTOS /MOVEIS
Private cProd22 := "DE000053|"
//Armazenagem
Private cProd23 := "DE000012|"
//Assistencia Medica e Social
Private cProd24 := "DE000030|DE000061|"
//Cartorio
Private cProd25 := "DE000040|"
//COMISSOES
Private cProd26 := "DE000062|"
//Condominios
Private cProd27 := "DE000076|"
//Consultoria
Private cProd28 := "DE000008|DE000009|"
//Correios e Malotes
Private cProd29 := "DE000039|"
//Energia Eletrica
Private cProd30 := "DE000003|"
//ESTACIONAMENTO EMPREGADOS
Private cProd31 := "DE000105|"
//ESTACIONAMENTO
Private cProd32 := "DE000018|"
//HOSPEDAGEM
Private cProd33 := "DE000016|"
//IDIOMAS
Private cProd34 := "DE000106|"
//Jornais, Revistas, Periodicos e Public.
Private cProd35 := "DE000063|"
//JOVEM APRENDIZ
Private cProd36 := "DE000084|"
//Manutencao de Maquinas e Equipamentos
Private cProd37 := "DE000024|"
//PASSAGEM AEREA
Private cProd38 := "DE000017|"
//Seguro de Vida em Grupo
Private cProd39 := "DE000031|"
//Vale Refeicao e Alimentacao
Private cProd40 := "DE000032|"
//Vale Transporte
Private cProd41 := "DE000034|"

//Regra
Do Case
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd1
		cRet := "51216017"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd2
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216004"
		Else
			cRet := "51216005"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd3
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216006"
		Else
			cRet := "51216007"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd4
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216005"
		Else
			cRet := "51216006"
		EndIf 
		
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd5
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216003"
		Else
			cRet := "51216004"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd6
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215003"
		Else
			cRet := "51215003"
		EndIf
	
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd7
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215010"
		Else
			cRet := "51215010"
		EndIf
	
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd8
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215002"
		Else
			cRet := "51215002"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd9
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42218003"
		Else
			cRet := "51218004"
		EndIf
	
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd10
		cRet := "51711013"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd11
		cRet := "51711006"
	
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd12
		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215005"
		Else
			cRet := "51215005"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd13
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42211004"
		Else
			cRet := "51211004"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd14
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212007"
		Else
			cRet := "51212007"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd15
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42218004"
		Else
			cRet := "51218005"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd16
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212003"
		Else
			cRet := "51212003"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd17
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215013"
		Else
			cRet := "51215013"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd18
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216024"
		Else
			cRet := "51216024"
		EndIf
	
	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd19
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212004"
		Else
			cRet := "51212004"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd20
   		cRet := "42212002"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd21
   		cRet := "42211001"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd22
   		cRet := "42216018"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd23
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212008"
		Else
			cRet := "51212008"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd24
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42112001"
		ElseIf ALLTRIM(SD1->D1_CC)+"|" $ cCentro2
	  		cRet := "51612001"
		Else
			cRet := "51112001"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd25
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212006"
		Else
			cRet := "51212006"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd26
   		cRet := "51711015"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd27
   		cRet := "51211002"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd28
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42215004"
		Else
			cRet := "51215004"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd29
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212005"
		Else
			cRet := "51212005"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd30
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42212001"
		Else
			cRet := "51212001"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd31
   		cRet := "42112007"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd32
   		cRet := "42218008"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd33
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42218009"
		Else
			cRet := "51218002"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd34
   		cRet := "51112011"

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd35
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42216009"
		Else
			cRet := "51216010"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd36
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42111014"
		Else
			cRet := "51111014"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd37
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "51213003"
		Else
			cRet := ""
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd38
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42218007"
		Else
			cRet := "51218003"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd39
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42112004"
		ElseIf ALLTRIM(SD1->D1_CC)+"|" $ cCentro2
	  		cRet := "51612004"
		Else
			cRet := "51112004"
		EndIf

	Case ALLTRIM(SD1->D1_COD)+"|" $ cProd40
   		If ALLTRIM(SD1->D1_CC)+"|" $ cCentro1
	  		cRet := "42112005"
		ElseIf ALLTRIM(SD1->D1_CC)+"|" $ cCentro2
	  		cRet := "51612005"
		Else
			cRet := "51112005"
		EndIf			
EndCase
     
//Caso não tenha encontrado a conta contabil, retorna a do cadastro do produto.
If EMPTY(cRet)
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
		cRet := SB1->B1_CONTA
	EndIf
EndIf

Return (cRet)