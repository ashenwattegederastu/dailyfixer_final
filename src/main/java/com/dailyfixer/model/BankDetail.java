package com.dailyfixer.model;

import java.sql.Timestamp;

public class BankDetail {
    private int bankDetailId;
    private int userId;
    private String bankName;
    private String branch;
    private String accountNumber;
    private String accountHolderName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getBankDetailId() { return bankDetailId; }
    public void setBankDetailId(int bankDetailId) { this.bankDetailId = bankDetailId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public String getBranch() { return branch; }
    public void setBranch(String branch) { this.branch = branch; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getAccountHolderName() { return accountHolderName; }
    public void setAccountHolderName(String accountHolderName) { this.accountHolderName = accountHolderName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
