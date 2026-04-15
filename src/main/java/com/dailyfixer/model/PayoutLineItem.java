package com.dailyfixer.model;

import java.math.BigDecimal;

public class PayoutLineItem {
    private int lineItemId;
    private int payoutId;
    private String sourceType;  // STORE_ORDER or DELIVERY
    private int sourceId;       // store_order_id or assignment_id
    private BigDecimal amount;

    public int getLineItemId() { return lineItemId; }
    public void setLineItemId(int lineItemId) { this.lineItemId = lineItemId; }

    public int getPayoutId() { return payoutId; }
    public void setPayoutId(int payoutId) { this.payoutId = payoutId; }

    public String getSourceType() { return sourceType; }
    public void setSourceType(String sourceType) { this.sourceType = sourceType; }

    public int getSourceId() { return sourceId; }
    public void setSourceId(int sourceId) { this.sourceId = sourceId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
}
