define view entity ZI_KEE_NE_ACTION
  as select from zkee_ne_action
  association to parent ZI_KEE_NE_STOCK as _Stock
    on  $projection.MaterialId = _Stock.MaterialId
    and $projection.BatchNo    = _Stock.BatchNo
{
    key action_id as ActionId,

    material_id as MaterialId,
    batch_no as BatchNo,
    priority as Priority,
    recommended_action as RecommendedAction,
    action_status as ActionStatus,

    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,

    _Stock
}
