trigger CreateIIFromLineItem on Line_Item__c (after update) {
    
    
    //Testing git
    
    if (!Recursive.isWorking()) {
  // trigger code here

    // Create Line Item, Inventory Item, and RecordType LISTS + Inventory Item Record Types MAP
    // Testing deploying application from Eclipse - 2nd test
    
    List <Line_Item__c> LIL = new List <Line_Item__c>([SELECT Id, Name, Product_Name__c, Item_Created__c , Product_Type__c, Unit_Price__c, Order_Complete__c, Quantity__c, 
                                                       Assigned_to__c, Purchase_Order__r.Date__c, Line_Item_Returned__c FROM Line_Item__c WHERE Id in :trigger.new]);
	          
    List <Inventory_Item__c> IIL = new List <Inventory_Item__c>();
        
	List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Inventory_Item__c' and isActive=true];
        
    List <Line_Item__c> LITOUPDATE = new List<Line_Item__c>();

	// Create a Map of InventoryItem Record Types and then loop through Inventory Items List and add them to the map.     
    Map<String,String> InventoryItemRecordTypes = new Map<String,String>{};

        
        
     for(RecordType rt: rtypes)

        InventoryItemRecordTypes.put(rt.Name,rt.Id);
    
    // Variables to add to the new Inventory Item
    
    	String CID = [SELECT Id FROM Contact WHERE Name ='Unassigned Product' LIMIT 1].Id;
    
    // Loop through the Line Item and create the Inventory Item

        For (Line_Item__c LI : LIL)
        {            

            IF (LI.Order_Complete__c==TRUE && LI.Item_Created__c == false && LI.Line_Item_Returned__c == false && LI.Assigned_to__c == null)
            {
        
        		For(Integer i = 0; LI.Quantity__c > i ; i++)
        			{
                                                
            		If (LI.Product_Type__c == 'Computer')
    					{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'Unassigned', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = CID, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Computer'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name);
                	IIL.add(II);
    					}
    		
    				if (LI.Product_Type__c == 'Mobile Device')
 	    	   			{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'Unassigned', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = CID, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Mobile Device'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name );
                	IIL.add(II);
    					}
    				if(LI.Product_Type__c == 'Other Inventory')
    					{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'Unassigned', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = CID, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Other Inventory'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name );	
                	IIL.add(II);
    					}
            	}
            }
            
            else if (LI.Order_Complete__c==TRUE && LI.Item_Created__c == false && LI.Line_Item_Returned__c == false && LI.Assigned_to__c != null)
            {
        
        		For(Integer i = 0; LI.Quantity__c > i ; i++)
        			{
                                                
            		If (LI.Product_Type__c == 'Computer')
    					{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'In Use', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = LI.Assigned_to__c, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Computer'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name);
                	IIL.add(II);
    					}
    		
    				if (LI.Product_Type__c == 'Mobile Device')
 	    	   			{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'In Use', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = LI.Assigned_to__c, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Mobile Device'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name );
                	IIL.add(II);
    					}
    				if(LI.Product_Type__c == 'Other Inventory')
    					{
        			Inventory_Item__c II = new Inventory_Item__c(Status__C = 'In Use', Purchase_Date__c = LI.Purchase_Order__r.Date__c, Assigned_to__c = LI.Assigned_to__c, 
                                                         RecordTypeId = InventoryItemRecordTypes.get('Other Inventory'), Product_Name__c = LI.Product_Name__c, 
                                                         Purchase_Price__c = LI.Unit_Price__c, Line_Item_ID__c = LI.id, Line_Item_Number__c = LI.Name );	
                	IIL.add(II);
    					}
            	}
            }
     }
			Database.insert(IIL, false) ;		
        
 // Update the Line Item Object with the Inventory Item ID in case it is needed in the future.               
			
    		List<Line_Item__c> LineItemsToUpdate = new  List<Line_Item__c>();  
    
           	For(Line_Item__c LITWO: LIL)
           {
               
               IF(LITWO.Order_Complete__c == TRUE)
               		{
                        System.debug(LITWO.Item_Created__c);
               			LITWO.Item_Created__c = TRUE;
                        System.debug(LITWO.Item_Created__c);
               			LineItemsToUpdate.add(LITWO);
                    }
           }
	    	Recursive.setWorking();
    		update LineItemsToUpdate;
	}
}