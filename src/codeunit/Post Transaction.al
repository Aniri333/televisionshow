codeunit 50112 "Post Transaction"
{
    TableNo = "Transaction Entry";

    trigger OnRun()
    begin
        ErrorIfNoEntriesToPost(rec);
        PostTransactions(Rec);
        ShowSuccessMessage();
    end;

    local procedure PostTransactions(var TransactionEntry: Record "Transaction Entry")
    begin
        if TransactionEntry.FindSet() then begin
            repeat
                VerifyTransactionEntry(TransactionEntry);
                PostTransactionEntry(TransactionEntry);
            until TransactionEntry.Next() = 0;

            TransactionEntry.DeleteAll();
        end;
    end;

    local procedure VerifyTransactionEntry(var TransactionEntry: Record "Transaction Entry")
    begin

        TransactionEntry.TestField("Transaction No.");
        TransactionEntry.TestField("Item No.");
        TransactionEntry.TestField(Quantity);
        TransactionEntry.TestField("Unit Cost");
        TransactionEntry.TestField("Suggested Unit Price");
        //TestField(Status, Status::Verified);
        TransactionEntry.TestField(Status, 1);
        OnAfterVerifyTransactionEntry(TransactionEntry);

    end;

    local procedure CopyFromTransaction(var FromSourceEntryNo: Integer; var ClearNewTransactionNo: Boolean; var GetNewUnitCost: Boolean)
    var
        OldTransaction: Record "Transaction Entry";
        NewTransaction: Record "Transaction Entry";
    begin
        OldTransaction.Get(FromSourceEntryNo);
        NewTransaction.Init();
        NewTransaction.TransferFields(OldTransaction, false);
        if ClearNewTransactionNo then
            NewTransaction."Transaction No." := '';
        if GetNewUnitCost then
            NewTransaction.GetLastDirectUnitCost();
        NewTransaction.Status := NewTransaction.Status::New;
        NewTransaction.Insert(true);
    end;

    local procedure PostTransactionEntry(var TransactionEntry: Record "Transaction Entry")
    var
        PostedTransactionEntry: Record "Posted Transaction Entry";
    begin
        PostedTransactionEntry.Init();
        PostedTransactionEntry.TransferFields(TransactionEntry);
        PostedTransactionEntry.Insert(true);
    end;

    local procedure ErrorIfNoEntriesToPost(var TransactionEntry: Record "Transaction Entry")
    var
        NoEntriesErr: Label 'There are no entries to post.';
    begin
        if TransactionEntry.IsEmpty() then
            Error(NoEntriesErr);
    end;

    local procedure ShowSuccessMessage()
    var
        EntriesPostedMsg: Label 'The entries have been posted.';
    begin
        if GuiAllowed then
            Message(EntriesPostedMsg);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterVerifyTransactionEntry(var TransactionEntry: Record "Transaction Entry")
    begin
    end;


}