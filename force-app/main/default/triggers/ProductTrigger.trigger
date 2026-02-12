trigger ProductTrigger on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            ProductTriggerHandler.handleBeforeUpdate(Trigger.new);
        }
    }
}