@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection view for stock'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZC_kee_NE_STOCK
  provider contract transactional_query
  as projection on ZI_KEE_NE_STOCK
{
    key MaterialId,
    key BatchNo,

    ManufactureDate,
    ExpiryDate,
    Quantity,
    Unit,
    Plant,
    StorageLocation,
    Vendor,

    RemainingDays,
    ExpiryStatus,
    Priority,
    RecommendedAction,

    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,

    _Action : redirected to composition child ZC_kee_NE_ACTION
}
