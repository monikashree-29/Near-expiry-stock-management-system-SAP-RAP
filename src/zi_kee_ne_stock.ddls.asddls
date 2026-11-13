@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for stock table'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_KEE_NE_STOCK
  as select from zkee_ne_stock

  composition [0..*] of ZI_kee_NE_ACTION as _Action
{
    key material_id as MaterialId,
    key batch_no   as BatchNo,

    manufacture_date as ManufactureDate,
    expiry_date      as ExpiryDate,
    quantity         as Quantity,
    unit             as Unit,
    plant            as Plant,
    storage_location as StorageLocation,
    vendor           as Vendor,

    remaining_days    as RemainingDays,
    expiry_status     as ExpiryStatus,
    priority          as Priority,
    recommended_action as RecommendedAction,

    @Semantics.user.createdBy: true
    local_created_by as LocalCreatedBy,

    @Semantics.systemDateTime.createdAt: true
    local_created_at as LocalCreatedAt,

    @Semantics.user.localInstanceLastChangedBy: true
    local_last_changed_by as LocalLastChangedBy,

    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,

    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,

    _Action
}
