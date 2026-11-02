/* Consecutivo del folio del recibo de pago (P-0000123). La usa el DEFAULT de Finanzas.Pago.Folio. */
CREATE SEQUENCE [Finanzas].[SeqFolioPago]
    AS INT
    START WITH 1
    INCREMENT BY 1
    NO CYCLE
    CACHE 10;
GO
