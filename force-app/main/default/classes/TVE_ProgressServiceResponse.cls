global with sharing class TVE_ProgressServiceResponse {
    
    public String error {get; set;}
    public ProgressBarWrap success {get; set;}
    public TVE_ProgressServiceResponse()
    {
        this.success = new ProgressBarWrap();
        this.success.statusList = new List<ProgressBarItem>();
    }
    
    public void setError(String msg)
    {
        this.error = msg;
        this.success = null;            
    }

    global class ProgressBarWrap {                
        public String referenceNumber {get; set;}
        public DateTime submittedDate {get; set;}
        public List<ProgressBarItem> statusList {get; set;}        
    }

    global class ProgressBarItem {                
        public Integer stepNumber {get; set;}
        public String statusTitle {get; set;}
        public Boolean isFirst {get; set;}
        public Boolean isCompleteStatus {get; set;}
        public Boolean isCurrentStatus {get; set;}
        public Boolean isFutureStatus {get; set;}
        public DateTime estimatedCompletionDate {get; set;}               
    }    
}