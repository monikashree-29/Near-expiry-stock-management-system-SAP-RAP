@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection view for action'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_kee_NE_ACTION as projection on ZI_KEE_NE_ACTION
{
    key ActionId,
    MaterialId,
    BatchNo,
    Priority,
    RecommendedAction,
    ActionStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Stock : redirected to parent ZC_kee_NE_STOCK
}
