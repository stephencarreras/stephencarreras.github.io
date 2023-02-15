<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" xmlns:avr="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:cec="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" xmlns:aife="urn:AIFE:Facture:Extension" version="1.0">
    <xsl:output method="html" indent="yes" standalone="yes" version="1.0"/>
    <xsl:decimal-format name="decformat" decimal-separator="," grouping-separator=" " digit="#" pattern-separator=";" NaN="NaN" minus-sign="-" zero-digit="0"/>
    <xsl:variable name="pays" select="document('../resources/iso_3166-1-a2-n3_fr.xml')"/>
    <xsl:variable name="UNECE4461_Subset" select="document('../resources/unece_4461_subset.xml')"/>
    <xsl:param name="modeIntegration"/>
    <xsl:template name="libPays">
        <xsl:param name="cod"/>
        <xsl:choose>
            <xsl:when test="$pays/ISO_3166-1_List_fr/ISO_3166-1_Entry[ISO_3166-1_Alpha-2_code=$cod]/ISO_3166-1_Country_name/text()">
                <xsl:value-of select="$pays/ISO_3166-1_List_fr/ISO_3166-1_Entry[ISO_3166-1_Alpha-2_code=$cod]/ISO_3166-1_Country_name/text()"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="libPaiement">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='10'">espèces (cash)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='20'">chèque (check)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='30'">virement (credit transfer)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='31'">virement (debit transfer)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='42'">virement (payment to bank account)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='48'">carte achat (bank card)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='49'">prélèvement (direct debit)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='50'">paiement par post virement (payment by postgiro)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='93'">virement de référence(reference giro)</xsl:when>
            <xsl:when test="//cac:PaymentMeans/cbc:PaymentMeansCode ='97'">report (clearing between partners)</xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="slash-date">
        <xsl:param name="datebrute"/>
        <xsl:value-of select="substring($datebrute, 9, 2)"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="substring($datebrute, 6, 2)"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="substring($datebrute, 1, 4)"/>
    </xsl:template>

    <xsl:template name="tokenizeNotes">

        <xsl:param name="list"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter)">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:value-of select="substring-before($list,$delimiter)"/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="tokenizeNotes">
                    <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$list = ''">
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="td">
                            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                            <xsl:attribute name="style">font-size:10px</xsl:attribute>
                            <xsl:value-of select="$list"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="position-espace">
        <xsl:param name="txt"/>
        <xsl:variable name="temp" select="substring($txt, string-length(string($txt)), 1)"/>
        <xsl:choose>
            <xsl:when test="contains(translate($txt,&quot;`~!@#$%^*()-_=+[]{}\|;:',.&gt;/?' &quot;,'§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§'),'§')">
                <xsl:choose>
                    <xsl:when test="contains(&quot;abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890&quot;, $temp)">
                        <xsl:call-template name="position-espace">
                            <xsl:with-param name="txt" select="substring($txt, 1, string-length(string($txt)) - 1)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string-length(string($txt))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string-length(string($txt))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="decoupeNotes">

        <xsl:param name="listeDecoupe"/>

        <xsl:choose>
            <xsl:when test="string-length(string($listeDecoupe)) &gt; 50">
                <xsl:variable name="last-index">
                    <xsl:call-template name="position-espace">
                        <xsl:with-param name="txt" select="substring($listeDecoupe, 1, 50)"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="style">font-size:10px</xsl:attribute>
                        <xsl:value-of select="substring($listeDecoupe, 1, $last-index)"/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="decoupeNotes">
                    <xsl:with-param name="listeDecoupe" select="substring($listeDecoupe, $last-index + 1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$listeDecoupe = ''">
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="td">
                            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                            <xsl:attribute name="style">font-size:10px</xsl:attribute>
                            <xsl:value-of select="$listeDecoupe"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="EnteteFacture">
        <xsl:param name="eltPere"/>
        <xsl:variable name="codePaiement" select="$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode/text()"/>
        <xsl:variable name="numCompte" select="$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID/text()"/>
        <xsl:element name="center">
            <xsl:element name="p">
                <xsl:attribute name="class">titre0</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 380">Facture Originale N°</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 382">Facture</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 383">Facture</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 384">Facture</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 385">Facture</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 386">Facture</xsl:when>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = 381">Avoir Originale N°</xsl:when>
                    <xsl:otherwise>Avoir</xsl:otherwise>
                </xsl:choose>
                 
                <xsl:value-of select="$eltPere/cbc:ID"/>
                <xsl:if test="$eltPere/cbc:IssueDate">
                    du 
                    <xsl:call-template name="slash-date">
                        <xsl:with-param name="datebrute" select="$eltPere/cbc:IssueDate"/>
                    </xsl:call-template>
                </xsl:if>

                <xsl:if test="$eltPere/cbc:InvoiceTypeCode/text() != '380' and $eltPere/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID/text()">
                    <br /> portant sur la facture : 
                    <xsl:value-of select="$eltPere/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID/text()"/>
                </xsl:if>
                <span style="font-size: 9pt">
                    <xsl:choose>
                        <xsl:when test="string-length(string($modeIntegration)) &gt; 0">
                            <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:StartDate"><br />Période de facturation du 
                                <xsl:call-template name="slash-date">
                                    <xsl:with-param name="datebrute" select="$eltPere/cac:InvoicePeriod/cbc:StartDate"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:StartDate"><br />Période de facturation du 
                                <xsl:call-template name="slash-date">
                                    <xsl:with-param name="datebrute" select="$eltPere/cac:InvoicePeriod/cbc:StartDate"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:EndDate">  au 
                        <xsl:call-template name="slash-date">
                            <xsl:with-param name="datebrute" select="$eltPere/cac:InvoicePeriod/cbc:EndDate"/>
                        </xsl:call-template>
                    </xsl:if>
                </span>
                <br />
                <span>
                    <xsl:attribute name="class">Recapitulatif1</xsl:attribute>
                    <xsl:if test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode">
                        <!-- <br/>  -->
                        <xsl:element name="tr">
                            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                            <xsl:element name="td">

                                <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                <xsl:attribute name="style">font-size:12pt</xsl:attribute>
                                <xsl:value-of select="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode"/>
                                <xsl:choose>
                                    <xsl:when test="$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode/text() = '1'">
                                         : Dépôt par un fournisseur d'une facture
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode/text() = '48'">
                                         : Dépôt par un fournisseur d'une facture déjà payée
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A3'">
                                         : Dépôt par un fournisseur d'un mémoire de frais de justice
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A4'">
                                         : Dépôt par un fournisseur d'un projet de décompte mensuel
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A5'">
                                         : Dépôt par un fournisseur d'un état d'acompte
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A6'">
                                         : Dépôt par un fournisseur d'un état d'acompte validé
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A7'">
                                         : Dépôt par un fournisseur d'un projet de décompte final
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A8'">
                                         : Dépôt par un fournisseur d'un décompte général signé
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A9'">
                                         : Dépôt par un sous-traitant d'une demande de paiement
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A10'">
                                         : Dépôt par un sous-traitant d'une demande de paiement dans le cadre des marchés de travaux
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A12'">
                                         : Dépôt par un cotraitant d'une facture
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A13'">
                                         : Dépôt par un cotraitant d'un projet de décompte mensuel
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A14'">
                                         : Dépôt par un cotraitant d'un projet de décompte final
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A15'">
                                         : Dépôt par une MOE d'un état d'acompte
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A16'">
                                         : Dépôt par une MOE d'un état d'acompte validé
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A17'">
                                         : Dépôt par une MOE d'un projet de décompte général
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A18'">
                                         : Dépôt par une MOE d'un décompte général
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A19'">
                                         : Dépôt par une MOA d'un état d'acompte validé
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A20'">
                                         : Dépôt par une MOA d'un décompte général
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A21'">
                                         : Dépôt par un bénéficiaire d'une demande de remboursement de la TIC
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A22'">
                                         : Dépôt par un fournisseur d'un projet de décompte général tacite
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A23'">
                                         : Dépôt par un fournisseur d'un décompte général et définitif dans le cadre d'une procédure tacite
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A24'">
                                         : Dépôt par une MOE d'un décompte général et définitif dans le cadre d'une procédure tacite tacite
                                    </xsl:when>
                                    <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A25'">
                                         : Dépôt par une MOA d'un décompte général et définitif tacite
                                    </xsl:when>
                                    <xsl:otherwise> A1 : Dépôt par un fournisseur d'une facture
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>


                    <xsl:for-each select="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/*">
                        <xsl:if test="name(.) = 'CategoryCode'">
                            <!--	<br/>   -->
                            <xsl:element name="tr">
                                <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif1</xsl:attribute>
                                    <xsl:attribute name="style">font-size:12pt</xsl:attribute>
                                    <xsl:value-of select="./text()"/>
                                    <xsl:choose>
                                        <xsl:when test="$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode/text() = '1'">
                                             : Dépôt par un fournisseur d'une facture
                                        </xsl:when>
                                        <xsl:when test="$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode/text() = '48'">
                                             : Dépôt par un fournisseur d'une facture déjà payée
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A3'">
                                             : Dépôt par un fournisseur d'un mémoire de frais de justice
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A4'">
                                             : Dépôt par un fournisseur d'un projet de décompte mensuel
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A5'">
                                             : Dépôt par un fournisseur d'un état d'acompte
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A6'">
                                             : Dépôt par un fournisseur d'un état d'acompte validé
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A7'">
                                             : Dépôt par un fournisseur d'un projet de décompte final
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A8'">
                                             : Dépôt par un fournisseur d'un décompte général signé
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A9'">
                                             : Dépôt par un sous-traitant d'une demande de paiement
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A10'">
                                             : Dépôt par un sous-traitant d'une demande de paiement dans le cadre des marchés de travaux
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A12'">
                                             : Dépôt par un cotraitant d'une facture
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A13'">
                                             : Dépôt par un cotraitant d'un projet de décompte mensuel
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A14'">
                                             : Dépôt par un cotraitant d'un projet de décompte final
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A15'">
                                             : Dépôt par une MOE d'un état d'acompte
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A16'">
                                             : Dépôt par une MOE d'un état d'acompte validé
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A17'">
                                             : Dépôt par une MOE d'un projet de décompte général
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A18'">
                                             : Dépôt par une MOE d'un décompte général
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A19'">
                                             : Dépôt par une MOA d'un état d'acompte validé
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A20'">
                                             : Dépôt par une MOA d'un décompte général
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A21'">
                                             : Dépôt par un bénéficiaire d'une demande de remboursement de la TIC
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A22'">
                                             : Dépôt par un fournisseur d'un projet de décompte général tacite
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A23'">
                                             : Dépôt par un fournisseur d'un décompte général et définitif dans le cadre d'une procédure tacite
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A24'">
                                             : Dépôt par une MOE d'un décompte général et définitif dans le cadre d'une procédure tacite tacite
                                        </xsl:when>
                                        <xsl:when test="./text() = 'A25'">
                                             : Dépôt par une MOA d'un décompte général et définitif tacite
                                        </xsl:when>
                                        <xsl:otherwise> </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </xsl:element>
        </xsl:element>

        <xsl:element name="table">
            <xsl:attribute name="width">100%</xsl:attribute>
            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
            <xsl:element name="tr">
                <xsl:element name="th">
                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                    Récapitulatif
                </xsl:element>
            </xsl:element>
            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:attribute name="style">padding: 15px</xsl:attribute>
                    <xsl:element name="table">
                        <xsl:attribute name="width">100%</xsl:attribute>
                        <xsl:element name="colgroup">
                            <xsl:element name="col">
                                <xsl:attribute name="width">50%</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="col">
                                <xsl:attribute name="width">50%</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <!-- Début des 4 montants récapitulatifs -->

                        <!-- Total HT et Total taxes  -->
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                Total HT
                                <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID">
                                     (
                                    <xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID"/>
                                    )
                                </xsl:if>
                            </xsl:element>
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif right</xsl:attribute>
                                <xsl:call-template name="number">
                                    <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                Total Taxes
                                <xsl:if test="$eltPere/cac:TaxTotal/cbc:TaxAmount/@currencyID">
                                     (
                                    <xsl:value-of select="$eltPere/cac:TaxTotal/cbc:TaxAmount/@currencyID"/>
                                    )
                                </xsl:if>
                            </xsl:element>
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif right</xsl:attribute>
                                <xsl:call-template name="number">
                                    <xsl:with-param name="num" select="$eltPere/cac:TaxTotal/cbc:TaxAmount"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                Total TTC
                                <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID">
                                     (
                                    <xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID"/>
                                    )
                                </xsl:if>
                            </xsl:element>
                            <xsl:element name="td">
                                <xsl:attribute name="class">Recapitulatif right</xsl:attribute>
                                <xsl:call-template name="number">
                                    <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>



                        <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount and not(string-length($eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/text())=0)">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    A déduire (déjà payé)
                                    <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID">
                                         (
                                        <xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID"/>
                                        )
                                    </xsl:if>
                                </xsl:element>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif right</xsl:attribute>
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount and not(string-length($eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/text())=0)">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    Net à payer
                                    <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID">
                                         (
                                        <xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/>
                                        )
                                    </xsl:if>
                                </xsl:element>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif right</xsl:attribute>
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>

                        <!-- Fin des 4 montants récapitulatifs -->


                        <!--Répartition Taxes -->
                        <xsl:if test="$eltPere/cac:TaxTotal/cac:TaxSubtotal">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="colspan">2</xsl:attribute>
                                    <xsl:element name="table">
                                        <xsl:attribute name="class">EnteteSite1</xsl:attribute>
                                        <xsl:element name="tr">
                                            <xsl:element name="td">
                                                <xsl:element name="b">Répartition des taxes</xsl:element>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="table">
                                        <xsl:attribute name="width">100%</xsl:attribute>
                                        <xsl:attribute name="style">bordered</xsl:attribute>
                                        <xsl:attribute name="cellpadding">0</xsl:attribute>
                                        <xsl:attribute name="cellspacing">2</xsl:attribute>

                                        <xsl:element name="thead">
                                            <xsl:element name="tr">
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">RecapSousTotauxleft</xsl:attribute>
                                                    Type Taxe
                                                </xsl:element>
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">RecapSousTotaux</xsl:attribute>
                                                    Taux Taxe
                                                </xsl:element>
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">RecapSousTotauxright</xsl:attribute>
                                                    Montant HT
                                                </xsl:element>
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">RecapSousTotauxright</xsl:attribute>
                                                    Montant Taxe
                                                </xsl:element>

                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="tbody">
                                            <xsl:for-each select="$eltPere/cac:TaxTotal/cac:TaxSubtotal">
                                                <xsl:element name="tr">
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">left</xsl:attribute>
                                                        <xsl:value-of select="./cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode/text()"/>
                                                         (
                                                        <xsl:value-of select="./cbc:TaxAmount/@currencyID"/>
                                                        )
                                                    </xsl:element>
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">center</xsl:attribute>
                                                        <xsl:call-template name="number">
                                                            <xsl:with-param name="num" select="./cbc:Percent/text()"/>
                                                        </xsl:call-template>
                                                    </xsl:element>
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">right</xsl:attribute>
                                                        <xsl:call-template name="number">
                                                            <xsl:with-param name="num" select="./cbc:TaxableAmount/text()"/>
                                                        </xsl:call-template>
                                                    </xsl:element>
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">right</xsl:attribute>
                                                        <xsl:call-template name="number">
                                                            <xsl:with-param name="num" select="./cbc:TaxAmount/text()"/>
                                                        </xsl:call-template>
                                                    </xsl:element>

                                                </xsl:element>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <xsl:element name="tr">
                            <xsl:element name="td"> </xsl:element>
                        </xsl:element>

                        <xsl:if test="$eltPere/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason/text()">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    Motif exonération :
                                </xsl:element>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                    <xsl:value-of select="$eltPere/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason/text()"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>

                        <xsl:if test="not($eltPere/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason/text())">
                            <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxExemptionReason/text()">
                                <xsl:element name="tr">
                                    <xsl:element name="td">
                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                        Motif exonération :
                                    </xsl:element>
                                    <xsl:element name="td">
                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                        <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxExemptionReason/text()"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                        </xsl:if>

                        <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    Total Remises
                                    <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/@currencyID">
                                         (
                                        <xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/@currencyID"/>
                                        )
                                    </xsl:if>
                                </xsl:element>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/text()"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount and not(string-length(/inv:Invoice/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/text())=0)">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    Montant charges <xsl:if test="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/@currencyID">  (<xsl:value-of select="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/@currencyID"/>) </xsl:if>
                                </xsl:element>
                                <xsl:element name="td">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>

                        <xsl:if test="$eltPere/cac:AllowanceCharge">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="colspan">2</xsl:attribute>
                                    <xsl:element name="table">
                                        <xsl:attribute name="class">EnteteSite</xsl:attribute>
                                        <xsl:element name="tr">
                                            <xsl:element name="td">
                                                <xsl:attribute name="class">EnteteSite</xsl:attribute>
                                                <xsl:element name="b">Répartition des remises et charges</xsl:element>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="table">
                                        <xsl:attribute name="width">100%</xsl:attribute>
                                        <xsl:attribute name="style">
                                            bordered
                                            collapsed
                                        </xsl:attribute>
                                        <xsl:attribute name="cellpadding">0</xsl:attribute>
                                        <xsl:attribute name="cellspacing">2</xsl:attribute>
                                        <xsl:element name="thead">
                                            <xsl:element name="tr">
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">bordered</xsl:attribute>
                                                    Type
                                                </xsl:element>
                                                <xsl:element name="th">
                                                    <xsl:attribute name="class">borderedright</xsl:attribute>
                                                    Montant
                                                </xsl:element>
                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="tbody">
                                            <xsl:for-each select="$eltPere/cac:AllowanceCharge">
                                                <xsl:element name="tr">
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">normal</xsl:attribute>

                                                        <xsl:if test="./cbc:ChargeIndicator = 'false'">
                                                            Remise : 
                                                        </xsl:if>
                                                        <xsl:if test="./cbc:ChargeIndicator = 'true'">
                                                            Charge : 
                                                        </xsl:if>

                                                        <xsl:value-of select="./cbc:AllowanceChargeReason/text()"/>
                                                         (
                                                        <xsl:value-of select="./cbc:Amount/@currencyID"/>
                                                        )
                                                    </xsl:element>
                                                    <xsl:element name="td">
                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                        <xsl:attribute name="class">right</xsl:attribute>
                                                        <xsl:call-template name="number">
                                                            <xsl:with-param name="num" select="./cbc:Amount/text()"/>
                                                        </xsl:call-template>
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>

                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:element name="table">
            <xsl:if test="count($eltPere/cbc:Note) &gt; 0">
                <xsl:element name="tr">
                    <xsl:element name="td"> </xsl:element>
                </xsl:element>
                <xsl:for-each select="$eltPere/cbc:Note">
                    <xsl:element name="tr">
                        <xsl:call-template name="tokenizeNotes">
                            <xsl:with-param name="list" select="./text()"/>
                            <xsl:with-param name="delimiter" select="'§'"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:for-each>
                <xsl:element name="tr">
                    <xsl:element name="td"> </xsl:element>
                </xsl:element>
            </xsl:if>




            <!-- GDR : 13072017 Si type =381  on affiche pas les mentions relative au paiement-->

            <xsl:if test="not($eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A2') and not($codePaiement='48')">
                <xsl:choose>
                    <xsl:when test="$eltPere/cbc:InvoiceTypeCode = '380' or $eltPere/cbc:InvoiceTypeCode = '382'  or $eltPere/cbc:InvoiceTypeCode = '383' or $eltPere/cbc:InvoiceTypeCode = '384' or $eltPere/cbc:InvoiceTypeCode = '385' or $eltPere/cbc:InvoiceTypeCode = '386' ">
                        <xsl:element name="tr">
                            <xsl:element name="td">

                                <xsl:attribute name="style">padding-left:23px;</xsl:attribute>
                                <!--    <xsl:attribute name="style">font-size:11px</xsl:attribute>  -->
                                <br />Paiement par
                                <xsl:call-template name="libPaiement">
                                    <xsl:with-param name="code" select="$codePaiement"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="($codePaiement='31'  or $codePaiement='30' or $codePaiement='42') and $numCompte">
                                        <xsl:choose>
                                            <xsl:when test="$eltPere/cac:PaymentMeans/cbc:PaymentChannelCode/text()='IBAN'"> sur le compte IBAN (BIC) :</xsl:when>
                                            <xsl:otherwise> sur le compte :</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                                <!-- JLJ 29-09-2019 : correction Path code BIC  -->
                                <xsl:if test="$codePaiement='31' or $codePaiement='30' or $codePaiement='42'">
                                    <xsl:choose>
                                        <xsl:when test="$numCompte">
                                            <xsl:choose>
                                                <xsl:when test="$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID">
                                                     <xsl:value-of select="$numCompte"/>
                                                    (
                                                    <xsl:value-of select="$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/>
                                                    )
                                                </xsl:when>
                                                <xsl:when test="$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID">
                                                     <xsl:value-of select="$numCompte"/>
                                                    (
                                                    <xsl:value-of select="$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID"/>
                                                    )
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$numCompte"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:element>
                        </xsl:element>


                        <xsl:if test="$eltPere/cac:PaymentMeans/cbc:PaymentDueDate">
                            <xsl:element name="tr">
                                <xsl:element name="td">
                                    <xsl:attribute name="style">font-weight:bold;padding-left:23px;</xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="$codePaiement='49'">
                                            <br />Cette somme sera prélevée à partir du :
                                        </xsl:when>
                                        <xsl:when test="$codePaiement='48'">
                                        </xsl:when>
                                        <xsl:otherwise><br />Nous vous remercions de votre règlement avant le : </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$codePaiement='48'">
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="slash-date">
                                                <xsl:with-param name="datebrute" select="$eltPere/cac:PaymentMeans/cbc:PaymentDueDate/text()"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>

                        <!--    <xsl:element name="tr">
                                    <xsl:element name="td"> </xsl:element>
                            </xsl:element>  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:if>

            <!-- Ajout  GDR -->
            <xsl:for-each select="$eltPere/cac:PaymentMeans/cbc:InstructionNote">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="style">font-size:0.9em; padding-left:23px</xsl:attribute>
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
            <!-- Fin Ajout  GDR -->
            <xsl:for-each select="$eltPere/cac:PaymentTerms/cbc:Note">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="style">padding-left:23px;</xsl:attribute>
                        <i><xsl:value-of select="./text()"/></i>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template name="Entete">
        <xsl:param name="eltPere"/>
        <xsl:element name="br"/>
        <xsl:element name="table">
            <xsl:attribute name="width">100%</xsl:attribute>
            <xsl:attribute name="cellpadding">0</xsl:attribute>
            <xsl:attribute name="cellspacing">0</xsl:attribute>
            <xsl:element name="colgroup">
                <xsl:element name="col">
                    <xsl:attribute name="width">48%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">4%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">48%</xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:attribute name="class">top</xsl:attribute>
                    <xsl:element name="table">
                        <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                        <xsl:element name="tr">
                            <xsl:element name="th">
                                <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                                Emetteur
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="EntiteJuridique">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="EntiteCommercial">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>

                                <xsl:call-template name="InformationsContactEntiteCommercial">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>

                                <xsl:call-template name="InformationsFournisseur">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="ContactFournisseur">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>

                    </xsl:element>
                    <br />
                    <xsl:call-template name="EntiteValideur">
                        <xsl:with-param name="eltPere" select="$eltPere"/>
                    </xsl:call-template>

                </xsl:element>
                <xsl:element name="td"> </xsl:element>
                <xsl:element name="td">
                    <xsl:attribute name="class">top</xsl:attribute>
                    <xsl:element name="table">
                        <xsl:attribute name="style">width: 100%</xsl:attribute>
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="EnteteClient">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>

                        <xsl:element name="tr">
                            <xsl:element name="td"> </xsl:element>
                        </xsl:element>
						
						<xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="EnteteServiceRecepteur">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>


                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:call-template name="EnteteEncaisseur">
                                    <xsl:with-param name="eltPere" select="$eltPere"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="EntiteJuridique">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity">
            <xsl:element name="table">
                <xsl:attribute name="class">SousEntete</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">SousEntete</xsl:attribute>
                        Entité juridique
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                    <xsl:attribute name="class">SousEntete</xsl:attribute>
                    <xsl:element name="td">
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <!-- AJout JLJ condition si pas streetname -->
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                    <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="cbc:Line"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                         
                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
                    </xsl:element>
                </xsl:element>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:call-template name="libPays">
                                <xsl:with-param name="cod" select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template name="EntiteValideur">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity">
            <xsl:element name="table">
                <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                        Valideur
                    </xsl:element>
                </xsl:element>

                <xsl:element name="tr">
                    <xsl:element name="td">RS : 
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cbc:RegistrationName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <!-- Ajout JLJ Condition si pas streetName -->
                <xsl:if test="not($eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName)">
                    <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="cbc:Line"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                         
                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
                    </xsl:element>
                </xsl:element>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:call-template name="libPays">
                                <xsl:with-param name="cod" select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <!--deb ajout SIRET Valideur-->
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification/cbc:ID">
                    <!--	<xsl:element name="table">  -->
                    <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:choose>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='1']">
                                    <xsl:choose>
                                        <xsl:when test="string-length($eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                        <xsl:otherwise> SIRET :  </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='2']">Structure Européenne hors France : </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='3']">Structure hors UE : </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='4']">RIDET : </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='5']">Numéro Tahiti : </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='6']">En cours dimmatriculation : </xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification[cbc:ID/@schemeName='6']">Particulier : </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="string-length($eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                        <xsl:otherwise> SIRET :  </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:PartyIdentification/cbc:ID/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <!--	</xsl:element>  -->
                </xsl:if>
                <!-- JLJ 26-09-2019 FIN ajout SIRET Valideur-->

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Name">
                    <xsl:attribute name="class">SousEntete</xsl:attribute>
                    <xsl:element name="tr">
                        <xsl:element name="th">
                            <xsl:attribute name="class">SousEntete</xsl:attribute>
                            <br />Contact
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Name/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Telephone">
                    <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Téléphone : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Telephone/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Telefax">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Télécopie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Telefax/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:ElectronicMail">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Messagerie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:ElectronicMail/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:AgentParty/cac:Contact/cbc:Note">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="./text()"/>

                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>

            </xsl:element>

        </xsl:if>

    </xsl:template>

    <xsl:template name="EntiteCommercial">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party">
            <xsl:element name="table">
                <xsl:attribute name="class">SousEntete</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">SousEntete</xsl:attribute>
                        Entité commerciale
                    </xsl:element>
                </xsl:element>
                <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyName">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:element name="b">
                                <xsl:value-of select="cbc:Name"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
                <!-- Ajout JLJ Condition Si AddressLine -->
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine">
                    <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                             
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <!--libellé du pays -->
                <!--AXYUS : 25/05/2016 ANNULATION report modifications concernant le libellé du pays :
                  QUESTION : est-ce pertinent d'avoir un IdentificationCode plutôt que son libellé, à moins que IdentificationCode contienne le libellé ?
                -->
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:call-template name="libPays">
                                <xsl:with-param name="cod" select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <!-- Ajout JLJ 29-09-2019 : Autre chemin pour adresse fournisseur  -->
                <xsl:if test="not($eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)">
                    <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:PostalAddress/cac:RegistrationAddress/cbc:AdditionalStreetName">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:PostalAddress/cac:RegistrationAddress/cbc:AdditionalStreetName"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                                 
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
                <!-- Fin Ajout -->

            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--AXYUS : 25/05/2016 report : 12/04/2016 FCA -->
    <xsl:template name="InformationsContactEntiteCommercial">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact">
            <xsl:element name="table">
                <xsl:attribute name="class">SousEntete</xsl:attribute>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID">
                    <xsl:element name="tr">
                        <xsl:element name="td"> Code service :  
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ID"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <!-- MODIF GDR 30/06 -->
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name">
                    <xsl:element name="tr">
                        <xsl:element name="td"> Nom service :  <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name"/>
                        </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Note">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>



            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="InformationsFournisseur">
        <xsl:param name="eltPere"/>
        <xsl:element name="table">
            <xsl:attribute name="class">SousEntete</xsl:attribute>
            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:choose>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='1']">
                            <xsl:choose>
                                <xsl:when test="string-length($eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                <xsl:otherwise> SIRET :  </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='2']">Structure Européenne hors France : </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='3']">Structure hors UE : </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='4']">RIDET : </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='5']">Numéro Tahiti : </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='6']">En cours d'immatriculation : </xsl:when>
                        <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='6']">Particulier : </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="string-length($eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                <xsl:otherwise> SIRET :  </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="b">
                        <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

            <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        Numéro de TVA intra-communautaire :
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

            <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text()">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        Régime de TVA : 
                        <xsl:element name="b">
                            <xsl:choose>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'TVA DEBIT'">TVA sur les débits</xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'TVA ENCAISSEMENT'">TVA sur les encaissements</xsl:when>
                                <xsl:when test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'EXONERATION'"> TVA exonérée </xsl:when>
                                <xsl:otherwise>
                                    Inconnu (code=
                                    <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text()"/>
                                    )
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        RCS : 
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ContactFournisseur">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact">
            <xsl:element name="table">
                <xsl:attribute name="class">SousEntete</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">SousEntete</xsl:attribute>
                        Contact
                    </xsl:element>
                </xsl:element>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Name/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Name/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telephone/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Téléphone : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telephone/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telefax/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Télécopie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telefax/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:ElectronicMail/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Messagerie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:ElectronicMail/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template name="EnteteClient">
        <xsl:param name="eltPere"/>
        <xsl:element name="table">
            <xsl:attribute name="class">EnteteClient</xsl:attribute>
            <xsl:element name="tr">
                <xsl:element name="th">
                    <xsl:attribute name="class">EnteteClient</xsl:attribute>
                    Client
                </xsl:element>
            </xsl:element>

            <!-- JLJ Ajout Sous titre Entité juridique -->
            <xsl:element name="tr">
                <xsl:element name="th">
                    <xsl:attribute name="class">SousEntete</xsl:attribute>
                    Entité
                </xsl:element>
            </xsl:element>
            <!-- JLJ FIN Ajout Sous titre Entité juridique -->

            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:element name="b">
                        <xsl:for-each select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name">
                            <xsl:value-of select="./text()"/>
                            <xsl:element name="br"/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <!-- Ajout JLJ : Condition si  adressLine -->
            <xsl:if test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine">
                <xsl:for-each select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>

            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
                </xsl:element>
            </xsl:element>

            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                     
                    <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                </xsl:element>
            </xsl:element>

            <xsl:if test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:call-template name="libPays">
                            <xsl:with-param name="cod" select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <!--      </xsl:element>  -->
            <!--      <xsl:element name="table">  -->
            <xsl:attribute name="class">EnteteClient</xsl:attribute>

            <xsl:element name="tr">
                <xsl:element name="th">
                    <xsl:attribute name="class">SousEntete</xsl:attribute>
                    Références
                </xsl:element>
            </xsl:element>

            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:element name="b">
                        <xsl:choose>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='1']">
                                <xsl:choose>
                                    <xsl:when test="string-length($eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                    <xsl:otherwise> SIRET : </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='2']">Structure Européenne hors France : </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='3']">Structure hors UE : </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='4']">RIDET : </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='5']">Numéro Tahiti : </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='6']">En cours d'immatriculation : </xsl:when>
                            <xsl:when test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='6']">Particulier : </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="string-length($eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                    <xsl:otherwise> SIRET :  </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:element name="b">
                        <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

            <xsl:if test="$eltPere/cac:OrderReference/cbc:ID">
                <xsl:element name="tr">
                    <xsl:element name="td"> Numéro d'engagement : <xsl:element name="b">
                        <xsl:value-of select="$eltPere/cac:OrderReference/cbc:ID"/>
                    </xsl:element>
                        <xsl:if test="$eltPere/cac:OrderReference/cbc:IssueDate/text()">  du  <xsl:call-template name="slash-date">
                            <xsl:with-param name="datebrute" select="$eltPere/cac:OrderReference/cbc:IssueDate/text()"/>
                        </xsl:call-template>
                        </xsl:if>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

            <!-- JLJ : Début de boucle sur de ContractDocumentReference -->
            <xsl:for-each select="$eltPere/cac:ContractDocumentReference">

                <!-- DEBUT Nouvelle gestion du label Marché public -->

                <xsl:if test="translate(cbc:DocumentTypeCode/text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='marché public'">
                    <xsl:if test="cbc:ID">
                        <xsl:element name="tr">
                            <xsl:element name="td">Marché :
                                <xsl:element name="b">
                                    <xsl:value-of select="cbc:ID"/>
                                </xsl:element>
                                <xsl:if test="cbc:IssueDate/text()">
                                     du 
                                    <xsl:call-template name="slash-date">
                                        <xsl:with-param name="datebrute" select="cbc:IssueDate/text()"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
                <!-- FIN de Nouvelle gestion du label Marché public -->


                <xsl:if test="cbc:DocumentTypeCode='Contrat'">
                    <xsl:element name="tr">
                        <xsl:element name="td">Contrat : <xsl:element name="b">
                            <xsl:value-of select="cbc:ID"/>
                        </xsl:element>
                            <xsl:if test="cbc:IssueDate/text()">  du 
                                <xsl:call-template name="slash-date">
                                    <xsl:with-param name="datebrute" select="cbc:IssueDate/text()"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="cbc:DocumentTypeCode='Bon de commande' and not($eltPere/cac:OrderReference/cbc:ID)">
                    <xsl:element name="tr">
                        <xsl:element name="td">Numéro d'engagement :
                            <xsl:element name="b">
                                <xsl:value-of select="cbc:ID"/>
                            </xsl:element>
                            <xsl:if test="cbc:IssueDate/text()">  du  <xsl:call-template name="slash-date">
                                <xsl:with-param name="datebrute" select="cbc:IssueDate/text()"/>
                            </xsl:call-template>
                            </xsl:if>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="cbc:DocumentTypeCode='Engagement' and not($eltPere/cac:OrderReference/cbc:ID)">
                    <xsl:element name="tr">
                        <xsl:element name="td">Numéro d'Engagement : <xsl:element name="b">
                            <xsl:value-of select="cbc:ID"/>
                        </xsl:element>
                            <xsl:if test="cbc:IssueDate/text()">  du  <xsl:call-template name="slash-date">
                                <xsl:with-param name="datebrute" select="cbc:IssueDate/text()"/>
                            </xsl:call-template>
                            </xsl:if>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

            </xsl:for-each>

            <!-- JLJ : Fin de boucle sur ContractDocumentReference -->



            <xsl:if test="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        Numéro de TVA Intra-communautaire : 
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID/text()"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:for-each select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Note">
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>

            <!-- début Ajout JLJ Code serv récepteur -->
            <xsl:if test="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:ID/text()">
                <xsl:attribute name="class">SousEntete</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">SousEntete</xsl:attribute>
                        <br />Service Récepteur
                    </xsl:element>
                </xsl:element>


                <xsl:element name="tr">
                    <xsl:element name="td">

                        <xsl:for-each select="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:ID">
                            Code : 
                            <xsl:element name="b">
                                <xsl:value-of select="./text()"/>
                                <xsl:element name="br"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
                <xsl:if test="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:Name/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Nom : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:Name"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
            <!-- Fin ajout code serv recept -->

        </xsl:element>
    </xsl:template>

    <xsl:template name="EnteteEncaisseur">
        <xsl:param name="eltPere"/>
        <xsl:if test="$eltPere/cac:PayeeParty/cac:PartyLegalEntity">
            <xsl:element name="table">
                <xsl:attribute name="class">EnteteServiceRecepteur</xsl:attribute>
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">EnteteServiceRecepteur</xsl:attribute>
                        Encaisseur
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                    <xsl:element name="td">
                        Nom : 
                        <xsl:element name="b">
                            <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyName/cbc:Name"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>

                <!-- Ajout JLJ : Condition si pas StreetName -->
                <xsl:if test="not($eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName)">
                    <xsl:for-each select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                        <xsl:element name="tr">
                            <xsl:element name="td">
                                <xsl:value-of select="cbc:Line"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName/text()">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                         
                        <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
                    </xsl:element>
                </xsl:element>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:call-template name="libPays">
                                <xsl:with-param name="cod" select="$eltPere/cac:PayeeParty/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <!--deb ajout SIRET Encaisseur-->
                <xsl:if test="$eltPere/cac:PayeeParty/cac:PartyIdentification/cbc:ID">
                    <!-- <xsl:element name="table">  -->
                    <xsl:attribute name="class">EnteteServiceRecepteur</xsl:attribute>
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <!-- <xsl:element name="b"> -->
                            <xsl:choose>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='1']">
                                    <xsl:choose>
                                        <xsl:when test="string-length($eltPere/cac:PayeeParty/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                        <xsl:otherwise> SIRET :  </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='2']">Structure Européenne hors France : </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='3']">Structure hors UE : </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='4']">RIDET : </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='5']">Numéro Tahiti : </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='6']">En cours d'immatriculation : </xsl:when>
                                <xsl:when test="$eltPere/cac:PayeeParty/cac:PartyIdentification[cbc:ID/@schemeName='6']">Particulier : </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="string-length($eltPere/cac:PayeeParty/cac:PartyIdentification/cbc:ID)=9">SIREN : </xsl:when>
                                        <xsl:otherwise> SIRET :  </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:PayeeParty/cac:PartyIdentification/cbc:ID/text()"/>
                            </xsl:element>
                            <!-- </xsl:element> -->
                        </xsl:element>
                    </xsl:element>
                    <!-- </xsl:element>  -->
                </xsl:if>
                <!--final ajout SIRET encaisseur-->

                <xsl:if test="$eltPere/cac:PayeeParty/cac:Contact/cbc:Name">
                    <xsl:attribute name="class">SousEntete</xsl:attribute>
                    <xsl:element name="tr">
                        <xsl:element name="th">
                            <xsl:attribute name="class">SousEntete</xsl:attribute>
                            <br />Contact
                        </xsl:element>
                    </xsl:element>

                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:PayeeParty/cac:Contact/cbc:Name/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:Contact/cbc:Telephone">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Téléphone : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:PayeeParty/cac:Contact/cbc:Telephone/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:Contact/cbc:Telefax">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Télécopie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:PayeeParty/cac:Contact/cbc:Telefax/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$eltPere/cac:PayeeParty/cac:Contact/cbc:ElectronicMail">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            Messagerie : 
                            <xsl:element name="b">
                                <xsl:value-of select="$eltPere/cac:PayeeParty/cac:Contact/cbc:ElectronicMail/text()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>

                <xsl:for-each select="$eltPere/cac:PayeeParty/cac:Contact/cbc:Note">
                    <xsl:element name="tr">

                        <xsl:element name="td">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>

            </xsl:element>



        </xsl:if>
    </xsl:template>

    <xsl:template name="EnteteSite">
        <xsl:param name="site"/>
        <xsl:param name="nbSite"/>

        <xsl:if test="$nbSite&gt;1">
            <xsl:element name="div">
                <xsl:attribute name="style">page-break-before:always</xsl:attribute>
            </xsl:element>
        </xsl:if>
        <xsl:element name="br"/>

    </xsl:template>
    <xsl:template name="EnteteSiteSansSite">
        <xsl:element name="div">
            <xsl:attribute name="style">page-break-before:always</xsl:attribute>
        </xsl:element>
        <xsl:element name="br"/>
        <xsl:element name="table">
            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
            <xsl:element name="tr">
                <xsl:element name="th">
                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                    <b>Articles rattachés au compte client</b>
                </xsl:element>
			<xsl:element name="tr">
                <xsl:element name="td">
                    <b>
                        Adresse de livraison :
                        <xsl:element name="br"/>
                    </b>
                    N° Client :
                    <xsl:value-of select="$site/cac:DeliveryLocation/cbc:ID"/>
                    <xsl:for-each select="$site/cac:DeliveryLocation/cac:Address/cac:AddressLine">
                        <xsl:element name="br"/>
                        <xsl:value-of select="cbc:Line"/>
                        <xsl:element name="br"/>
                    </xsl:for-each>
                    <xsl:value-of select="$site/cac:DeliveryLocation/cac:Address/cbc:PostalZone"/>
                    
                    <xsl:value-of select="$site/cac:DeliveryLocation/cac:Address/cbc:CityName"/>
                    <xsl:element name="br"/>
                    <xsl:if test="$site/cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode">
                        <xsl:call-template name="libPays">
                            <xsl:with-param name="cod"
                                            select="$site/cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="LigneFacture">
        <!-- JLJ : Ajout condition sur affichage ligne de facture sur site de livraison -->


        <xsl:param name="lignes"/>

        <!--   JLJ Modification site de livraison dans tableau -->
        <xsl:element name="table">
            <xsl:attribute name="width">100%</xsl:attribute>
            <xsl:attribute name="style">bordered collapsed; page-break-inside: avoid;</xsl:attribute>
            <xsl:attribute name="cellpadding">0</xsl:attribute>
            <xsl:attribute name="cellspacing">2</xsl:attribute>
            <xsl:attribute name="style">font-size: 0.9em;</xsl:attribute>

            <xsl:attribute name="class">Recapitulatif</xsl:attribute>


            <xsl:element name="colgroup">
                <xsl:element name="col">
                    <xsl:attribute name="width">5%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">45%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">10%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">11%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">10%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">9%</xsl:attribute>
                </xsl:element>
                <xsl:element name="col">
                    <xsl:attribute name="width">10%</xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:element name="thead">
                <xsl:element name="tr">
                    <xsl:element name="th">
                        <xsl:attribute name="class">bordered</xsl:attribute>
                        TVA
                    </xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="class">bordered</xsl:attribute>
                        Num BL
                    </xsl:element>
                    <xsl:element name="th">
                        <xsl:attribute name="class">bordered</xsl:attribute>
                        Dénomination de l'article
                    </xsl:element>
                    <xsl:element name="th">
                        <xsl:attribute name="class">borderedright</xsl:attribute>
                        <span>Quantité facturée</span>
                    </xsl:element>
                    <xsl:element name="th">
                        <xsl:attribute name="class">borderedright</xsl:attribute>
                        Prix unitaire Brut HT
                    </xsl:element>
					<xsl:element name="th">
                        <xsl:attribute name="class">borderedright</xsl:attribute>
                        Prix unitaire Net HT
                    </xsl:element>
                    <xsl:element name="th">
                        <xsl:attribute name="class">borderedright</xsl:attribute>
                        Remise %
                    </xsl:element>
                    <xsl:element name="th">
                        <xsl:attribute name="class">borderedright</xsl:attribute>
                        Total HT après remise
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tbody">
                <xsl:for-each select="$lignes">
                    <xsl:element name="tr">
                        <xsl:element name="td">
                            <xsl:attribute name="class">top left</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="cac:Item/cac:ClassifiedTaxCategory/cbc:Percent">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cac:Item/cac:ClassifiedTaxCategory/cbc:Percent"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
						<xsl:element name="td">
                            <xsl:attribute name="class">top left</xsl:attribute>
                            <xsl:if test="./cac:Delivery/cbc:ID">
                                <xsl:value-of select="./cac:Delivery/cbc:ID"/>
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="td">
                            <table cellspacing="0" cellpadding="0" border="0">
                                <xsl:attribute name="class">left</xsl:attribute>
                                <xsl:if test="cac:Item/cbc:Name">
                                    <tr>
                                        <td>
                                            <xsl:if test="./cbc:ID">
                                                <xsl:value-of select="./cbc:ID"/>
                                                -
                                            </xsl:if>
                                            <xsl:value-of select="cac:Item/cbc:Name"/>
                                        </td>
                                    </tr>
                                </xsl:if>

                                <!--AXYUS : 25/05/2016 report : 12/04/2016 FAC : Ajout type et sous-type ZZZZ -->

                                <xsl:if test="cac:Item/cac:AdditionalItemProperty">
                                    <tr>
                                        <td>
                                            <!-- transformation du libellé en focntion du type de ligne GDR 04/07-->
                                            <xsl:choose>
                                                <xsl:when test="./cac:Item/cac:AdditionalItemProperty/cbc:Name ='TYPE_LIGNE'">Ligne</xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                            <xsl:choose>
                                                <xsl:when test="./cac:Item/cac:AdditionalItemProperty/cbc:Value ='INFORMATION'"> d information</xsl:when>
                                                <xsl:when test="./cac:Item/cac:AdditionalItemProperty/cbc:Value ='REGROUPEMENT'"> de regroupement</xsl:when>
                                                <xsl:when test="./cac:Item/cac:AdditionalItemProperty/cbc:Value ='DETAIL'"> de détail</xsl:when>
                                            </xsl:choose>

                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="cac:Item/cbc:Description">
                                    <tr>

                                        <td>
                                            <xsl:for-each select="cac:Item/cbc:Description">
                                                <xsl:element name="tr">
                                                    <xsl:element name="td">

                                                        <xsl:value-of select="./text()"/>

                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:for-each>
                                        </td>
                                    </tr>
                                </xsl:if>

                                <xsl:if test="cac:Item/cac:StandardItemIdentification !='' or cac:Item/cac:SellersItemIdentification !=''">
                                    <tr>
                                        <td>Référence produit : 

                                            <xsl:if test="cac:Item/cac:SellersItemIdentification/cbc:ID">
                                                <xsl:value-of select="./cac:Item/cac:SellersItemIdentification/cbc:ID"/>
                                            </xsl:if>
                                            <xsl:if test="cac:Item/cac:StandardItemIdentification !='' and cac:Item/cac:SellersItemIdentification !=''">
                                                  -  
                                            </xsl:if>
                                            <xsl:if test="cac:Item/cac:StandardItemIdentification">
                                                <xsl:value-of select="cac:Item/cac:StandardItemIdentification/cbc:ID"/>
                                            </xsl:if>
                                        </td>
                                    </tr>
                                </xsl:if>

                                <!-- Début 17/05/2019 : UGAP - Sollicitation 126851  Affichage de la date de livraison pour l'ensemble des postes de facture -->
                                <xsl:if test="cac:Delivery/cbc:ActualDeliveryDate/text() != '' or cac:Delivery/cbc:TrackingID/text() != ''">
                                    <tr>
                                        <td>
                                            <xsl:if test="cac:Delivery/cbc:ActualDeliveryDate/text() != ''">
                                                Date de livraison :
                                                <xsl:call-template name="slash-date">
                                                    <xsl:with-param name="datebrute" select="cac:Delivery/cbc:ActualDeliveryDate/text()"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                            <xsl:if test="cac:Delivery/cbc:ActualDeliveryDate/text() != '' and cac:Delivery/cbc:TrackingID/text() != ''">
                                                -
                                            </xsl:if>
                                            <xsl:if test="cac:Delivery/cbc:TrackingID">
                                                N° bon de livraison :
                                                <xsl:value-of select="cac:Delivery/cbc:TrackingID/text()"/>
                                            </xsl:if>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <!-- Fin Ajout sollicitation UGAP -->


                                <xsl:for-each select="cbc:Note">
                                    <xsl:choose>
                                        <xsl:when test="string-length(string($modeIntegration)) &gt; 0">
                                            <tr>
                                                <xsl:call-template name="decoupeNotes">
                                                    <xsl:with-param name="listeDecoupe" select="./text()"/>
                                                </xsl:call-template>
                                            </tr>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <tr>
                                                <xsl:call-template name="tokenizeNotes">
                                                    <xsl:with-param name="list" select="./text()"/>
                                                    <xsl:with-param name="delimiter" select="'§'"/>
                                                </xsl:call-template>
                                            </tr>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </table>
                        </xsl:element>
                        <xsl:element name="td">
                            <xsl:attribute name="class">top right</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="cbc:InvoicedQuantity">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cbc:InvoicedQuantity"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="cbc:CreditedQuantity">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cbc:InvoicedQuantity"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
						<xsl:element name="td">
                            <xsl:attribute name="class">top right</xsl:attribute>
                            <xsl:call-template name="number">
                                <xsl:with-param name="num"
                                                select="number(cac:AllowanceCharge/cbc:BaseAmount/text()) div number(cbc:InvoicedQuantity/text())"/>
                            </xsl:call-template>
                        </xsl:element>
                        <xsl:element name="td">
                                <xsl:choose>
                                <xsl:when test="cac:Price/cbc:PriceAmount">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cac:Price/cbc:PriceAmount"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                        <xsl:element name="td">
                            <xsl:attribute name="class">top right</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="cac:AllowanceCharge/cbc:MultiplierFactorNumeric">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num"
                                                        select="number(cac:AllowanceCharge/cbc:MultiplierFactorNumeric/text()) *100"/>%
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise></xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                        <xsl:element name="td">
                            <xsl:attribute name="class">top right</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="cbc:LineExtensionAmount">
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cbc:LineExtensionAmount"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise></xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                        <xsl:element name="td">





                            <xsl:choose>
                                <xsl:when test="cbc:LineExtensionAmount">
                                    <xsl:choose>
                                        <xsl:when test="cbc:LineExtensionAmount &gt; 1000000">
                                            <xsl:attribute name="class">top rightMilion</xsl:attribute>
                                    <xsl:call-template name="number">
                                        <xsl:with-param name="num" select="cbc:LineExtensionAmount"/>
                                    </xsl:call-template>
                                </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="class">top right</xsl:attribute>
                                            <xsl:call-template name="number">
                                                <xsl:with-param name="num" select="cbc:LineExtensionAmount"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:element>
					
					<!-- description produit -->

                    <xsl:element name="tr">
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                            <xsl:attribute name="class">top normal</xsl:attribute>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <xsl:if test="cac:Item/cbc:Name">
                                    <tr>
                                        <td>
                                            <xsl:value-of select="cac:Item/cbc:Name"/>
                                        </td>
                                    </tr>
                                </xsl:if>

                                <xsl:if test="cac:Item/cac:AdditionalItemProperty">
                                    <tr>
                                        <td>
                                            <xsl:if test="./cac:Item/cac:AdditionalItemProperty/cbc:Name">
                                                <xsl:value-of select="./cac:Item/cac:AdditionalItemProperty/cbc:Name"/>
                                                -
                                            </xsl:if>
                                            <xsl:if test="./cac:Item/cac:AdditionalItemProperty/cbc:Value">
                                                <xsl:value-of select="./cac:Item/cac:AdditionalItemProperty/cbc:Value"/>
                                            </xsl:if>
                                        </td>
                                    </tr>
                                </xsl:if>

                                <xsl:if test="cac:Item/cbc:Description">
                                    <tr>
                                        <td style="font-size: 9px;">
                                            <xsl:for-each select="cac:Item/cbc:Description">
                                                <xsl:value-of select="./text()"/>
                                                 
                                            </xsl:for-each>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </table>
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                        <xsl:element name="td">
                             
                        </xsl:element>
                    </xsl:element>
					
					<!-- multi tva -->
                    <xsl:choose>
                        <xsl:when test="count(./cac:TaxTotal/cac:TaxSubtotal)>1">
                            <xsl:for-each select="./cac:TaxTotal/cac:TaxSubtotal">
                                <xsl:element name="tr">
                                    <xsl:attribute name="class">MultiTva</xsl:attribute>
                                    <xsl:element name="td">
                                        <xsl:attribute name="class">top right MultiTva</xsl:attribute>
                                        <xsl:call-template name="number">
                                            <xsl:with-param name="num" select="cbc:Percent"/>
                                        </xsl:call-template>
                                    </xsl:element>
                                    <xsl:element name="td">
                                          
                                    </xsl:element>
                                    <xsl:element name="td">
                                        <xsl:attribute name="class">top right MultiTva</xsl:attribute>
                                        détail TVA
                                        <xsl:call-template name="number">
                                            <xsl:with-param name="num" select="cbc:Percent"/>
                                        </xsl:call-template>

                                    </xsl:element>
                                    <xsl:element name="td">
                                         
                                    </xsl:element>
                                    <xsl:element name="td">
                                         
                                    </xsl:element>
                                    <xsl:element name="td">
                                         
                                    </xsl:element>
                                    <xsl:element name="td">
                                         
                                    </xsl:element>
                                    <xsl:element name="td">
                                        <xsl:attribute name="class">top right MultiTva</xsl:attribute>
                                        <xsl:call-template name="number">
                                            <xsl:with-param name="num" select="cbc:TaxableAmount"/>
                                        </xsl:call-template>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>

                    <!-- fin multi tva -->
					
                </xsl:for-each>

                <xsl:element name="tr">
                    <xsl:element name="td">
                        <xsl:attribute name="colspan">6</xsl:attribute>
                        <xsl:attribute name="class">TotauxSite</xsl:attribute>
                        <b>Totaux du site de livraison, pour information :</b>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                    <xsl:attribute name="height">15px</xsl:attribute>
                    <xsl:element name="td"> </xsl:element>
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="colspan">5</xsl:attribute>
                        Brut HT
                    </xsl:element>






                    <xsl:choose>
                        <xsl:when test="sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount)-sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)+sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount) &gt; 1000000">
                            <xsl:element name="td">
                                <xsl:attribute name="class">top</xsl:attribute>
                                <xsl:attribute name="class">rightboldMilion</xsl:attribute>
                                <xsl:call-template name="number">
                                    <xsl:with-param name="num" select="format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount)-sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)+sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount),'######0.0000;-#######.0000')"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                    <xsl:element name="td">
                        <xsl:attribute name="class">top</xsl:attribute>
                        <xsl:attribute name="class">rightbold</xsl:attribute>
                        <xsl:call-template name="number">
                            <xsl:with-param name="num" select="format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount)-sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)+sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount),'######0.0000;-#######.0000')"/>
                        </xsl:call-template>
                    </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>





                </xsl:element>
                <xsl:element name="tr">
                    <xsl:attribute name="height">15px</xsl:attribute>
                    <xsl:element name="td"> </xsl:element>
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="colspan">5</xsl:attribute>
                        Remises/charges à la ligne
                    </xsl:element>
                    <xsl:element name="td">
                        <xsl:attribute name="class">top</xsl:attribute>
                        <xsl:attribute name="class">rightbold</xsl:attribute>

                        <xsl:call-template name="number">
                            <xsl:with-param name="num" select="format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)-sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount),'######0.0000;-#######.0000')"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                    <xsl:attribute name="height">15px</xsl:attribute>
                    <xsl:element name="td"> </xsl:element>
                    <xsl:element name="td">
                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                        <xsl:attribute name="colspan">5</xsl:attribute>
                        Net HT
                    </xsl:element>



                    <xsl:choose>
                        <xsl:when test="sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount) &gt; 1000000">
                            <xsl:element name="td">
                                <xsl:attribute name="class">top</xsl:attribute>
                                <xsl:attribute name="class">rightboldMilion</xsl:attribute>
                                <xsl:call-template name="number">
                                    <xsl:with-param name="num" select="format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount),'######0.0000;-#######.0000')"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                    <xsl:element name="td">
                        <xsl:attribute name="class">top</xsl:attribute>
                        <xsl:attribute name="class">rightbold</xsl:attribute>
                        <xsl:call-template name="number">
                            <xsl:with-param name="num" select="format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount),'######0.0000;-#######.0000')"/>
                        </xsl:call-template>
                    </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>




                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="PiedSite"/>
    <xsl:template name="PiedClient"/>
    <xsl:template name="PiedFournisseur">
        <xsl:param name="eltPere"/>
        <xsl:element name="br"/>
        <xsl:element name="p">
            <xsl:attribute name="style">font-size: 10px</xsl:attribute>
            <xsl:element name="center">
                <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
                 -
                <xsl:for-each select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                     
                    <xsl:value-of select="cbc:Line/text()"/>
                </xsl:for-each>

                  <xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>

                  <xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:AdditionalStreetName"/>

                  <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>

                  <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode">
                     (
                    <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode"/>)
                    <xsl:call-template name="libPays">
                        <xsl:with-param name="cod" select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode"/>
                    </xsl:call-template>
                </xsl:if>

                <xsl:element name="br"/>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:CorporateRegistrationScheme/cbc:ID">
                    Capital social : 
                    <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:CorporateRegistrationScheme/cbc:ID/text()"/>
                     - 
                </xsl:if>

                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID">
                      Immatriculation RCS : <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()"/>
                </xsl:if>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
                     - 
                    Numéro de TVA intra-communautaire :
                     
                    <xsl:value-of select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID/text()"/>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="PiedFacture"/>
    <xsl:template name="number">
        <xsl:param name="num"/>
        <xsl:choose>
            <xsl:when test="string-length(string($num)) = 0"/>
            <xsl:when test="number($num) = 0">0,00</xsl:when>
            <xsl:when test="string(number($num)) = 'NaN'"/>

            <xsl:when test="string-length(substring-after(string($num), '.')) &gt; 2">
                <xsl:value-of select="format-number($num,'# ### ##0,00####;-# ### ###,00####','decformat')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number($num,'# ### ##0,00;-# ### ###,00','decformat')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="initHtml">
        <xsl:param name="eltPere"/>
        <html>
            <head>
                <xsl:choose>
                    <xsl:when test="$eltPere/cac:InvoiceLine">
                        <title>Facture Fournisseur</title>
                    </xsl:when>
                    <xsl:otherwise>
                        <title>Avoir Fournisseur</title>
                    </xsl:otherwise>
                </xsl:choose>

                <style type="text/css" media="print">
                    .invoiceDiv {
                    width: 100%;
                    }
                    td {
                    text-align: left;
                    }
                    .Recapitulatif1{
                    width: 200mm;
                    text-align: center;
                    }
                    @page  {
                    size: A4 portrait;
                    @bottom-center {
                    content: "Page " counter(page);
                    }
                    }

                </style>
                <style type="text/css" media="screen">
                    .invoiceDiv {
                    width: 190mm;
                    }
                </style>
                <style type="text/css" media="all">

                    body, p, th, td {
                    font-size: 9pt;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    }
                    .version {
                    font-size: 7pt;
                    font-style: italic;
                    /* color:#FFFFFF; */
                    }
                    .titre0 {
                    font-weight: bold;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 15pt;
                    color: #006d99;
                    }
                    .center {
                    text-align: center;
                    font-size: 9pt;
                    }
                    .top {
                    vertical-align: top;
                    }
                    .gras {
                    font-weight: bold;
                    }
                    .italic {
                    font-style: italic;
                    }
                    .left {
                    text-align: left;
                    padding-left:5px;
                    font-size: 9pt;
                    }
                    .normal {
                    font-style: normal;
                    font-weight: normal;
                    }
                    .right {
                    text-align: right;
                    padding-right:5px;
                    font-size: 9pt;
                    }
                    .rightMilion {
                    text-align: right;
                    padding-right:5px;
                    font-size: 7pt;
                    }
                    .rightbold {
                    text-align: right;
                    font-size: 9pt;
                    font-weight: bold;
                    padding-right:5px;
                    }
                    .rightboldMilion {
                    text-align: right;
                    font-size: 7pt;
                    font-weight: bold;
                    padding-right:5px;
                    }
                    .bordered {
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    padding: 5px;
                    background-color: #e4e4e4;
                    color: #006d99;
                    }
                    .borderedright {
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    text-align:right;
                    padding: 5px;
                    background-color: #e4e4e4;
                    color: #006d99;
                    }
                    .borderedleft {
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    text-align:left;
                    padding: 5px;
                    background-color: #e4e4e4;
                    color: #006d99;
                    }
                    .collapsed {
                    border-collapse: collapse;
                    border-spacing: 0px;
                    }
                    .titre1 {
                    margin-top: 12px;
                    margin-bottom: 0px;
                    font-wieght: bold;
                    font-size: 9pt;
                    }
                    .nosign {
                    list-style-type: none;
                    }

                    table.EnteteFournisseur {
                    margin: 0;
                    border-style: solid;
                    border-width: 1px;
                    <!-- jlj_ajout box-shadow + modif couleur border -->
                    border: 1px solid #E4E4E4;
                    box-shadow: 4px 4px 6px #aaa;
                    width: 100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    text-align: left;
                    padding: 23px;
                    padding-left: 23px;
                    page-break-inside: avoid;
                    }

                    th.EnteteFournisseur {
                    font-size: 13pt;
                    text-align: left;
                    padding: 5px;
                    <!-- background-color: #999999;
                    background-color: #006d99; -->
                    <!-- jlj_ajout color  -->
                    color : #006d99;
                    border-bottom : 1px solid #006d99;
                    }

                    td.EnteteFournisseur {
                    font-size: 9pt;
                    text-align: left;
                    padding: 5px;
                    <!-- jlj_ajout color  -->
                    color : black;
                    }

                    table.SousEntete {
                    padding-left: 5px;
                    }

                    th.SousEntete {
                    font-size: 10pt;
                    text-align: left;
                    padding-left: 0px;
                    <!-- jlj_ajout color
                    color : #878788;  -->
                    color : #717171
                    }

                    td.SousEntete {
                    font-size: 15pt;
                    }

                    table.EnteteClient {
                    margin: 0;
                    border-style: solid;
                    border-width: 1px;
                    <!-- jlj_ajout box-shadow + modif couleur border -->
                    border: 1px solid #E4E4E4;
                    box-shadow: 4px 4px 6px #aaa;
                    width: 100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    text-align: left;
                    padding: 23px;
                    page-break-inside: avoid;
                    }

                    th.EnteteClient {
                    font-size: 13pt;
                    text-align: left;
                    padding: 5px;
                    <!--background-color: #999999;
                    background-color: #f0f0f0;
                    background-color: #006d99; -->
                    <!-- jlj_ajout color  -->
                    color : #006d99;
                    border-bottom : 1px solid #006d99;
                    }

                    td.EnteteClient {
                    font-size: 9pt;
                    }

                    table.EnteteServiceRecepteur{
                    margin:0;
                    border-style:solid;
                    border-width:1px;
                    <!-- jlj_ajout box-shadow + modif couleur border -->
                    border: 1px solid #E4E4E4;
                    box-shadow: 4px 4px 6px #aaa;
                    <!--   border-color:black;  -->
                    width:100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size:9pt;
                    text-align:left;
                    padding:23px;
                    padding-left: 23px;
                    page-break-inside:avoid;
                    }

                    th.EnteteServiceRecepteur{
                    font-size:13pt;
                    text-align:left;
                    padding:5px;
                    <!--background-color: #999999;
                    background-color: #006d99; -->
                    <!-- jlj_ajout color  -->
                    color : #006d99;
                    border-bottom: 1px solid #006d99;
                    }

                    table.EnteteSite {
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    padding: 23px;
                    margin: 0;
                    width: 100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 13pt;
                    text-align: left;
                    page-break-inside: avoid;
                    <!--background-color: #999999;
                     background-color: #f0f0f0; -->
                    <!-- jlj_ajout color
                    background-color: #e4e4e4; -->
                    color : #006d99;
                    }

                    table.EnteteSite1 {
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    padding-top: 10px;
                    margin: 0;
                    width: 100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 13pt;
                    text-align: left;
                    page-break-inside: avoid;
                    <!--background-color: #999999;
                     background-color: #f0f0f0; -->
                    <!-- jlj_ajout color
                    background-color: #e4e4e4; -->
                    color : #006d99;
                    }



                    table.Recapitulatif {
                    border-style: none;
                    padding: 23px;
                    margin: 0;
                    width: 100%;
                    <!-- jlj_ajout box-shadow + modif couleur border -->
                    border: 1px solid #E4E4E4;
                    box-shadow: 4px 4px 6px #aaa;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    text-align: left;
                    background-color: none;
                    page-break-inside: avoid;
                    }

                    th.Recapitulatif {
                    font-size: 11pt;
                    font-weight: bold;
                    text-align: left;
                    padding: 5px;
                    <!-- jlj_ajout color  -->
                    background-color: none;
                    border-bottom: 1px solid #006d99;
                    color: #006d99;
                    }

                    td.Recapitulatif {
                    font-size: 9pt;
                    font-weight:bold;
                    }

                    table.RecapSousTotaux {
                    margin: 0;
                    border-style: solid;
                    border-width: 1px;
                    border-color: black;
                    width: 100%;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    text-align: left;
                    padding: 23px;
                    page-break-inside: avoid;
                    }

                    th.RecapSousTotaux {
                    font-size: 9pt;
                    text-align: center;
                    padding: 5px;
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    color: #006d99;
                    background-color: #e4e4e4;
                    }

                    th.RecapSousTotauxleft {
                    font-size: 9pt;
                    text-align: left;
                    padding: 5px;
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    color: #006d99;
                    background-color: #e4e4e4;
                    }

                    th.RecapSousTotauxright {
                    font-size: 9pt;
                    text-align: right;
                    padding: 5px;
                    border-style: solid;
                    border-width: 0px;
                    border-color: black;
                    color: #006d99;
                    background-color: #e4e4e4;
                    }

                    td.RecapSousTotaux {
                    text-align: left;
                    padding: 5px;
                    font-size: 9pt;
                    }

                    .Recapitulatif1{
                    font-weight: bold;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    }

                    .TotauxSite {
                    font-weight: bold;
                    font-family: Calibri, Tahoma, Arial, verdana, sans-serif;
                    font-size: 9pt;
                    color: #006d99;
                    padding-top:15px;
                    }

                    .PaiementPar {
                    padding-left:23px;
                    }
                </style>

            </head>
            <body>
                <span class="version">Facture Fournisseur (FSO1100) : 20210106-01</span>
                <!--
               20170328 : Ajout de la référence fabriquant au niveau de la ligne
               20170329 : Ajout du mode de paiement 42 et 48 pour afficher les références banques
               20170630 : - Regroupement dans un même bloc des information de contact fournisseur
                          - Gestion des retours à al ligne
                          - Transcodification des lignes de type détail, information, regroupement
                          - Modification libellé tableau Quantité de livraison en Unité de prix
                          - Suppression balise entête sur génération PDF
                          - Instruction de paiement reprise pour Seres
                          - Prise en compte de la ligne adresse et complément du site de livraison en entête
               20170713
                          - Si Avoir suppression des mentions moyen de paiement et date
                          - remontée des informations client dans le bloc client et non pas récepteur
               20181010
                          -V1.3.4 IT5
               20181121
                          - Formatage du texte des notes pour eviter l'édition d'une facture tronquée
                          - Modification de la largeur du bloc recapitulatif pour les impressions et génération pdf
                          - Correction de l'anomalie de présentation de la date de la période de facturation
               20190327
                          - Correction de l'affichage du code service pour le fournisseur
               20190503
                          - Correction de l'alignement du texte
               20191219
                          - Modification par L'AIFE JLJ pour correction des pbi 47889 et 47891
               20200219
                          - Correction du motif exonération non visible
               20201221
                          - Correction de l'affichage de date de livraison
                          - Correction de la méthode "position-espace"
              20210106
                          - Modification  de l'affichage de date de livraison
                              -->

                <xsl:for-each select="$eltPere">
                    <xsl:call-template name="Entete">
                        <xsl:with-param name="eltPere" select="$eltPere"/>
                    </xsl:call-template>
                    <xsl:call-template name="EnteteFacture">
                        <xsl:with-param name="eltPere" select="$eltPere"/>
                    </xsl:call-template>

                    <xsl:variable name="nbDelivery" select="count(cac:Delivery)"/>
                    <xsl:if test="$nbDelivery&gt;1">
                        <xsl:element name="table">
                            <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                            <xsl:element name="tr">
                                <xsl:element name="th">
                                    <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                    Détails de facturation par site de livraison
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>

                    <!-- Nouvelle gestion du site de livraison selon info entete -->
                    <xsl:for-each select="$eltPere/cac:Delivery">
                        <xsl:variable name="nbDeliveryID" select="count($eltPere/cac:InvoiceLine/cac:Delivery[cbc:ID != ''] )"/>
                        <xsl:variable name="SiteID1" select="cac:DeliveryLocation/cbc:ID"/>
                        <xsl:variable name="SiteID2" select="cbc:ID"/>
                        <!--Site de livraison-->
                        <xsl:if test="$nbDelivery=1">
                            <xsl:call-template name="EnteteSite">
                                <xsl:with-param name="site" select="."/>
                                <xsl:with-param name="nbSite" select="$nbDelivery"/>
                            </xsl:call-template>
                            <xsl:variable name="lignes1" select="$eltPere/cac:InvoiceLine[cac:Delivery/cbc:ID = $SiteID1 or cac:Delivery/cbc:ID = $SiteID2 or( $nbDeliveryID=0   )] "/>
                            <xsl:call-template name="LigneFacture">
                                <xsl:with-param name="lignes" select="$lignes1"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$nbDelivery&gt;1">
                            <xsl:variable name="lignes1" select="$eltPere/cac:InvoiceLine[cac:Delivery/cbc:ID = $SiteID1 or cac:Delivery/cbc:ID = $SiteID2] "/>
                            <xsl:if test="$lignes1!=''">
                                <xsl:call-template name="EnteteSite">
                                    <xsl:with-param name="site" select="."/>
                                    <xsl:with-param name="nbSite" select="$nbDelivery"/>
                                </xsl:call-template>
                                <xsl:call-template name="LigneFacture">
                                    <xsl:with-param name="lignes" select="$lignes1"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:variable name="nbDeliveryID1" select="count($eltPere/cac:InvoiceLine/cac:Delivery[cbc:ID != ''] )"/>
                    <xsl:if test="$eltPere/cac:InvoiceLine[not(cac:Delivery/cbc:ID=$eltPere/cac:Delivery/cac:DeliveryLocation/cbc:ID) and not(cac:Delivery/cbc:ID=$eltPere/cac:Delivery/cbc:ID)]and ($nbDeliveryID1!=0 or $nbDelivery!=1 )">
                        <xsl:call-template name="EnteteSiteSansSite"/>
                        <xsl:call-template name="LigneFacture">
                            <!--Lignes rattachées au client-->
                            <xsl:with-param name="lignes" select="$eltPere/cac:InvoiceLine[not(cac:Delivery/cbc:ID=$eltPere/cac:Delivery/cac:DeliveryLocation/cbc:ID) and not(cac:Delivery/cbc:ID=$eltPere/cac:Delivery/cbc:ID)]"/>
                        </xsl:call-template>
                    </xsl:if>
                    <!-- Fin de la nouvelle gestion du site de livraison -->



                    <xsl:if test="$eltPere/cac:CreditNoteLine">
                        <xsl:call-template name="EnteteSiteSansSite"/>
                        <xsl:call-template name="LigneFacture">
                            <xsl:with-param name="lignes" select="$eltPere/cac:CreditNoteLine"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:call-template name="PiedClient"/>
                    <xsl:call-template name="PiedFournisseur">
                        <xsl:with-param name="eltPere" select="$eltPere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="/">
        <xsl:if test="/inv:Invoice">
            <xsl:call-template name="initHtml">
                <xsl:with-param name="eltPere" select="/inv:Invoice"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="/avr:CreditNote">
            <xsl:call-template name="initHtml">
                <xsl:with-param name="eltPere" select="/avr:CreditNote"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
